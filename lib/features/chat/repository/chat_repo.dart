import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/model/user_model.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/enums/message_enums.dart';
import '../../../../model/chat_contact_model.dart';
import '../../../../model/message_model.dart';
import '../../../core/failure.dart';
import '../../../core/type_defs.dart';
import '../../../core/utils.dart';

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
  Stream<List<ChatContactModel>> getChatContacts() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContactModel> contacts = [];
      for (var document in event.docs) {
        var chatContact = ChatContactModel.fromMap(document.data());
        var userData =
            await _firestore.collection('users').doc(chatContact.contactId).get();
        var user = UserModel.fromMap(userData.data()!);
        contacts.add(
          ChatContactModel(
            name: user.name,
            profilePic: user.profilePic,
            contactId: chatContact.contactId,
            timeSent: chatContact.timeSent,
            lastMessage: chatContact.lastMessage,
          ),
        );
      }
      return contacts;
    });
  }
  Stream<List<MessageModel>> getChatStream(String receiverUserId) {
    return _users
        .doc(_auth.currentUser!.uid)
        .collection('chats')
        .doc(receiverUserId)
        .collection('messages')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .map((event) {
      List<MessageModel> messages = [];
      for (var document in event.docs) {
        messages.add(MessageModel.fromMap(document.data()));
      }
      return messages;
    });
  }

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
          );
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
    var receiverChatContact = ChatContactModel(
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
    var senderChatContact = ChatContactModel(
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
  }) async {
    final message = MessageModel(
      senderId: _auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
    );
    await _users
        .doc(_auth.currentUser!.uid)
        .collection(FirebaseConstants.chatsCollection)
        .doc(receiverUserId)
        .collection(FirebaseConstants.messagesCollection)
        .doc(messageId)
        .set(message.toMap());
    final receiverMessage = MessageModel(
      senderId: _auth.currentUser!.uid,
      receiverId: receiverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
    );
    await _users
        .doc(receiverUserId)
        .collection(FirebaseConstants.chatsCollection)
        .doc(_auth.currentUser!.uid)
        .collection(FirebaseConstants.messagesCollection)
        .doc(messageId)
        .set(receiverMessage.toMap());
  }

  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String receiverUserId,
    required UserModel senderUserData,
    required String imageUrl,
    required MessageEnum messageEnum,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();
      UserModel receiverUserData;
      var receiverData = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(receiverUserId)
          .get();
      receiverUserData = UserModel.fromMap(receiverData.data()!);
      String contactMsg;
      switch (messageEnum) {
        case MessageEnum.image:
          contactMsg = '📷 Photo';
          break;
        case MessageEnum.video:
          contactMsg = '📸 Video';
          break;
        case MessageEnum.audio:
          contactMsg = '🎵 Audio';
          break;
        default:
          contactMsg = 'File';
      }
      _saveDataToContactsSubCollection(
        senderUserData,
        receiverUserData,
        contactMsg,
        timeSent,
        receiverUserId,
      );

      _saveChatToMessagesSubCollection(
        receiverUserId: receiverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        messageType: messageEnum,
        receiverUserName: receiverUserData.name,
        senderUsername: senderUserData.name,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  FutureVoid deleteChat(
    String receiverUserId,
  ) async {
    try {
      deleteAllMessages(receiverUserId);
      return right(
        _users
            .doc(_auth.currentUser!.uid)
            .collection(FirebaseConstants.chatsCollection)
            .doc(receiverUserId)
            .delete(),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void deleteAllMessages(String receiverUserId) async {
    try {
      var messages = await _users
          .doc(_auth.currentUser!.uid)
          .collection(FirebaseConstants.chatsCollection)
          .doc(receiverUserId)
          .collection(FirebaseConstants.messagesCollection)
          .get();
      for (var message in messages.docs) {
        await _users
            .doc(_auth.currentUser!.uid)
            .collection(FirebaseConstants.chatsCollection)
            .doc(receiverUserId)
            .collection(FirebaseConstants.messagesCollection)
            .doc(message.id)
            .delete();
      }
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }
Stream<bool> isNewMessage(String receiverUserId) {
    return _users
        .doc(_auth.currentUser!.uid)
        .collection(FirebaseConstants.chatsCollection)
        .doc(receiverUserId)
        .collection(FirebaseConstants.messagesCollection)
        .snapshots()
        .map((event) {
      return event.docs.isNotEmpty;
    });
  }
}
