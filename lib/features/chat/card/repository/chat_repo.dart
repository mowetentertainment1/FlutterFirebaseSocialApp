import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/model/user.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/enums/message_enum.dart';
import '../../../../model/chat_contact.dart';
import '../../../../model/message.dart';

final chatRepoProvider = Provider((ref) {
  return ChatRepo(firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance);
});

class ChatRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  ChatRepo({required FirebaseFirestore firestore, required FirebaseAuth auth})
      : _firestore = firestore,
        _auth = auth;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);
  void sendTextMessage(
      {required String message,
      required UserModel senderUser,
      required String receiverUserId,
      required BuildContext context}) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v4();
      UserModel receiverUserData;
      var receiverData = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(receiverUserId)
          .get();
      receiverUserData = UserModel.fromMap(receiverData.data()!);
      _saveDataToContactsSubCollection(
          senderUser, receiverUserData, message, timeSent, receiverUserId);
      _saveChatToMessagesSubCollection(
          receiverUserId: receiverUserId,
          text: message,
          timeSent: timeSent,
          messageId: messageId,
          username: receiverUserData.name,
          messageType: MessageEnum.text,
          senderUsername: senderUser.name,
          receiverUserName: receiverUserData.name,
          isGroupChat: false);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  void _saveDataToContactsSubCollection(
      UserModel senderUserData,
      UserModel receiverUserData,
      String message,
      DateTime timeSent,
      String receiverUserId) async {
    var receiverChatContact = ChatContact(
      name: senderUserData.name,
      profilePic: senderUserData.profilePic,
      contactId: senderUserData.uid,
      timeSent: timeSent,
      lastMessage: message,
    );
    await _users
        .doc(receiverUserId)
        .collection(FirebaseConstants.chatsCollection)
        .doc(senderUserData.uid)
        .set(receiverChatContact.toMap());
    var senderChatContact = ChatContact(
      name: receiverUserData.name,
      profilePic: receiverUserData.profilePic,
      contactId: receiverUserData.uid,
      timeSent: timeSent,
      lastMessage: message,
    );
    await _users
        .doc(senderUserData.uid)
        .collection(FirebaseConstants.chatsCollection)
        .doc(receiverUserData.uid)
        .set(senderChatContact.toMap());
  }

  void _saveChatToMessagesSubCollection({
    required String receiverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required String senderUsername,
    required String? receiverUserName,
    required bool isGroupChat,
  }) async {
    final message = Message(
      senderId: _auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: '',
      repliedTo: '',
      repliedMessageType: MessageEnum.text,
    );
    await _users
        .doc(_auth.currentUser!.uid)
        .collection(FirebaseConstants.chatsCollection)
        .doc(receiverUserId)
        .collection(FirebaseConstants.messagesCollection)
        .doc(messageId)
        .set(message.toMap());
    final receiverMessage = Message(
      senderId: _auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: '',
      repliedTo: '',
      repliedMessageType: MessageEnum.text,
    );
    await _users
        .doc(receiverUserId)
        .collection(FirebaseConstants.chatsCollection)
        .doc(_auth.currentUser!.uid)
        .collection(FirebaseConstants.messagesCollection)
        .doc(messageId)
        .set(receiverMessage.toMap());
  }
}
