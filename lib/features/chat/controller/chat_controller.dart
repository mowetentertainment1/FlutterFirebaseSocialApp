import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/storage_repository_provider.dart';
import '../../../../core/utils.dart';
import '../../../core/enums/message_enums.dart';
import '../../../model/chat_contact_model.dart';
import '../../../model/message_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../repository/chat_repo.dart';
final chatControllerProvider = StateNotifierProvider<ChatController, bool>((ref) {
  final chatRepo = ref.watch(chatRepoProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return ChatController(
    chatRepo: chatRepo,
    ref: ref,
    storageRepository: storageRepository,
  );
});
final chatStream =
    StreamProvider.family<List<MessageModel>, String>((ref, receiverUserId) {
  return ref.read(chatControllerProvider.notifier).getChatStream(receiverUserId);
});
final getReceiverChatContact =
    StreamProvider.family<ChatContactModel, String>((ref, receiverUserId) {
  return ref.read(chatControllerProvider.notifier).getReceiverChatContact(receiverUserId);
});
final getUnreadMessagesCount = StreamProvider<int>((ref) {
  return ref.read(chatControllerProvider.notifier).getUnreadMessagesCount();
});

class ChatController extends StateNotifier<bool> {
  final ChatRepo _chatRepo;
  final Ref _ref;
  final StorageRepository _storageRepository;
  Stream<List<ChatContactModel>> chatContactList() {
    return _chatRepo.getChatContacts();
  }

  Stream<ChatContactModel> getReceiverChatContact(String receiverUserId) {
    return _chatRepo.getReceiverChatContact(receiverUserId);
  }

  void updateReceiverUnreadMessagesCount(receiverUserId) {
    _chatRepo.updateReceiverUnreadMessagesCount(receiverUserId);
  }

  void updateCurrentUnreadMessagesCount(receiverUserId) {
    _chatRepo.updateCurrentUnreadMessagesCount(receiverUserId);
  }

  ChatController({
    required ChatRepo chatRepo,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _chatRepo = chatRepo,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void sendTextMessage(BuildContext context, String message, String receiverUserId,
      String receiverUserToken) async {
    state = true;
    try {
      _ref.read(getCurrentUserDataProvider).whenData(
            (value) => _chatRepo.sendTextMessage(
              message: message,
              senderUser: value,
              receiverUserId: receiverUserId,
              context: context,
              receiverUserToken: receiverUserToken,
            ),
          );
      state = false;
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Stream<List<MessageModel>> getChatStream(String receiverUserId) {
    return _chatRepo.getChatStream(receiverUserId);
  }

  Stream<int> getUnreadMessagesCount() {
    return _chatRepo.getTotalUnreadMessagesCount();
  }

  Future<void> sendFileMessage(
    BuildContext context,
    File file,
    String receiverUserId,
    String receiverUserToken,
    MessageEnum messageEnum,
  ) async {
    state = true;
    switch (messageEnum) {
      case MessageEnum.image:
        final imageSave = await _storageRepository.storeFile(
          path: 'chat/$receiverUserId/',
          id: const Uuid().v1(),
          file: file,
        );
        final imageUrl = imageSave.fold((l) => '', (r) => r);
        _ref.read(getCurrentUserDataProvider).whenData(
              (value) => _chatRepo.sendFileMessage(
                context: context,
                file: file,
                receiverUserId: receiverUserId,
                receiverUserToken: receiverUserToken,
                senderUserData: value,
                messageEnum: messageEnum,
                imageUrl: imageUrl,
              ),
            );
        break;
      case MessageEnum.audio:
        final audioSave = await _storageRepository.storeAudio(
          path: 'chat/$receiverUserId/',
          file: file,
        );
        final audioUrl = audioSave.fold((l) => '', (r) => r);
        _ref.read(getCurrentUserDataProvider).whenData(
              (value) => _chatRepo.sendFileMessage(
                context: context,
                file: file,
                receiverUserId: receiverUserId,
                receiverUserToken: receiverUserToken,
                senderUserData: value,
                messageEnum: messageEnum,
                imageUrl: audioUrl,
              ),
            );
        break;
      case MessageEnum.video:
        final videoSave = await _storageRepository.storeVideo(
          path: 'chat/$receiverUserId/',
          file: file,
        );
        final videoUrl = videoSave.fold((l) => '', (r) => r);
        _ref.read(getCurrentUserDataProvider).whenData(
              (value) => _chatRepo.sendFileMessage(
                context: context,
                file: file,
                receiverUserId: receiverUserId,
                receiverUserToken: receiverUserToken,
                senderUserData: value,
                messageEnum: messageEnum,
                imageUrl: videoUrl,
              ),
            );
        break;
      default:
        break;
    }
    state = false;
  }

  void deleteChat(String receiverUserId, BuildContext context) async {
    final res = await _chatRepo.deleteChat(receiverUserId);
    final deleteChatFiles =
        await _storageRepository.deleteChatFiles(receiverUserId: receiverUserId);
    deleteChatFiles.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'File Deleted');
    });
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Deleted successfully!');
    });
  }

  void setChatMessageSeen(
    String receiverUserId,
    String messageId,
  ) {
    _chatRepo.setChatMessageSeen(
      receiverUserId,
      messageId,
    );
  }
  void blockUser(String receiverUserId) {
    _chatRepo.blockUserMessage(receiverUserId);
  }
  void unBlockUser(String receiverUserId) {
    _chatRepo.unBlockUserMessage(receiverUserId);
  }
  void muteUser(String receiverUserId) {
    _chatRepo.muteUserMessage(receiverUserId);
  }
  void unMuteUser(String receiverUserId) {
    _chatRepo.unMuteUserMessage(receiverUserId);
  }

}
