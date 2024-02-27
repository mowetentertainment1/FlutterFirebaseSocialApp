import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/model/community_chat_model.dart';
import 'package:untitled/model/community_message_model.dart';
import 'package:untitled/model/user_model.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/enums/message_enum.dart';
import '../../../core/failure.dart';
import '../../../core/type_defs.dart';
import '../../../core/utils.dart';
import '../../../model/community_model.dart';

final communityChatRepoProvider = Provider((ref) {
  return CommunityChatRepo(
      firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance);
});

class CommunityChatRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  CommunityChatRepo({required FirebaseFirestore firestore, required FirebaseAuth auth})
      : _firestore = firestore,
        _auth = auth;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);
  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
  Stream<List<CommunityChatModel>> getChatGroups() {
    return _firestore
        .collection(FirebaseConstants.communitiesCollection)
        .where("members", arrayContains: _auth.currentUser!.uid)
        .snapshots()
        .map((event) {
      List<CommunityChatModel> chats = [];
      for (var doc in event.docs) {
        var community = CommunityModel.fromMap(doc.data());
        chats.add(
          CommunityChatModel(
            name: community.name,
            timeSent: DateTime.now(),
            lastMessage: '',
            senderId: '',
            communityId: community.id,
            groupPic: community.avatar,
            membersUid: community.members,
          ),
        );
      }
      return chats;
    });
  }

  Stream<List<CommunityMessageModel>> getChatStream(String communityId) {
    return _communities
        .doc(communityId)
        .collection(FirebaseConstants.chatsCollection)
        .doc('GeneralChat')
        .collection(FirebaseConstants.messagesCollection)
        .orderBy('timeSent', descending: true)
        .snapshots()
        .map((event) {
      List<CommunityMessageModel> messages = [];
      for (var doc in event.docs) {
        messages.add(CommunityMessageModel.fromMap(doc.data()));
      }
      return messages;
    });
  }

  void sendTextMessage(
      {required String message,
      required UserModel senderUser,
      required String receiverCommunityId,
      required BuildContext context}) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v4();
      CommunityModel receiverUserData;
      var receiverData = await _firestore
          .collection(FirebaseConstants.communitiesCollection)
          .doc(receiverCommunityId)
          .get();
      receiverUserData = CommunityModel.fromMap(receiverData.data()!);
      _saveDataToContactsSubCollection(
          senderUser, receiverUserData, message, timeSent, receiverCommunityId);
      _saveChatToMessagesSubCollection(
        receiverCommunityId: receiverCommunityId,
        text: message,
        timeSent: timeSent,
        messageId: messageId,
        username: receiverUserData.name,
        messageType: MessageEnum.text,
        senderUsername: senderUser.name,
        senderProfilePic: senderUser.profilePic,
        senderUid: senderUser.uid,
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }

  void _saveDataToContactsSubCollection(
      UserModel senderUserData,
      CommunityModel receiverCommunityData,
      String message,
      DateTime timeSent,
      String receiverCommunityId) async {
    var senderChatContact = CommunityChatModel(
      name: receiverCommunityData.name,
      timeSent: timeSent,
      lastMessage: message,
      senderId: senderUserData.uid,
      communityId: receiverCommunityData.id,
      groupPic: receiverCommunityData.avatar,
      membersUid: receiverCommunityData.members,
    );
    await _communities
        .doc(receiverCommunityData.id)
        .collection(FirebaseConstants.chatsCollection)
        .doc(senderUserData.uid)
        .set(senderChatContact.toMap());
  }

Stream<bool> checkUserIsModerator(String communityId, String userId){
    return _firestore
        .collection(FirebaseConstants.communitiesCollection)
        .doc(communityId)
        .snapshots()
        .map((event) {
          if (event.data()!.containsKey('mods')) {
            List<String> moderators = event.data()!['mods'];
            if (moderators.contains(userId)) {
              return true;
            }
          }
          return false;
    });
}

  void _saveChatToMessagesSubCollection({
    required String receiverCommunityId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required String senderUsername,
    required String senderProfilePic,
    required String senderUid,

  }) async {
    // final message = MessageModel(
    //   senderId: _auth.currentUser!.uid,
    //   receiverId: receiverCommunityId,
    //   text: text,
    //   type: messageType,
    //   timeSent: timeSent,
    //   messageId: messageId,
    //   isSeen: false,
    //   repliedMessage: '',
    //   repliedTo: senderUsername,
    //   repliedMessageType: MessageEnum.text,
    // );
    // await _users
    //     .doc(_auth.currentUser!.uid)
    //     .collection(FirebaseConstants.chatsCollection)
    //     .doc(receiverCommunityId)
    //     .collection(FirebaseConstants.messagesCollection)
    //     .doc(messageId)
    //     .set(message.toMap());
    Stream<bool> isModerator =
    checkUserIsModerator(receiverCommunityId, senderUid);
    bool isMod = false;
    isModerator.listen((event) {
      isMod = event;
    });

    final receiverMessage = CommunityMessageModel(
      senderId: _auth.currentUser!.uid,
      receiverId: receiverCommunityId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      senderProfilePic: senderProfilePic,
      senderUsername: senderUsername,
      isModerator: isMod,
    );
    await _communities
        .doc(receiverCommunityId)
        .collection(FirebaseConstants.chatsCollection)
        .doc('GeneralChat')
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

      CommunityModel? receiverCommunityData;
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
        receiverCommunityData!,
        contactMsg,
        timeSent,
        receiverUserId,
      );

      _saveChatToMessagesSubCollection(
        receiverCommunityId: receiverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        messageType: messageEnum,
        senderUsername: senderUserData.name,
        senderProfilePic: senderUserData.profilePic,
        senderUid: senderUserData.uid,
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
}
