import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/storage_repository_provider.dart';
import '../../../../core/utils.dart';
import '../../../core/enums/message_enum.dart';
import '../../../model/chat_contact.dart';
import '../../../model/message.dart';
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
final chatStream = StreamProvider.family<List<Message>, String>((ref, receiverUserId) {
  return ref.read(chatControllerProvider.notifier).getChatStream(receiverUserId);
});

class ChatController extends StateNotifier<bool> {
  final ChatRepo _chatRepo;
  final Ref _ref;
  final StorageRepository _storageRepository;
  Stream<List<ChatContact>> chatContacts() {
    return _chatRepo.getChatContacts();
  }

  ChatController({
    required ChatRepo chatRepo,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _chatRepo = chatRepo,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void sendTextMessage(BuildContext context, String message, String receiverUserId) {
    state = true;
    try {
      _ref.read(getCurrentUserDataProvider).whenData((user) {
        _chatRepo.sendTextMessage(
          message: message,
          senderUser: user!,
          receiverUserId: receiverUserId,
          context: context,
        );
      });
      state = false;
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Stream<List<Message>> getChatStream(String receiverUserId) {
    return _chatRepo.getChatStream(receiverUserId);
  }

  Future<void> sendFileMessage(
    BuildContext context,
    File file,
    String receiverUserId,
    MessageEnum messageEnum,
    bool isGroupChat,
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
                senderUserData: value!,
                messageEnum: messageEnum,
                imageUrl: imageUrl,
                isGroupChat: isGroupChat,
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
                senderUserData: value!,
                messageEnum: messageEnum,
                imageUrl: audioUrl,
                isGroupChat: isGroupChat,
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
                senderUserData: value!,
                messageEnum: messageEnum,
                imageUrl: videoUrl,
                isGroupChat: isGroupChat,
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
}
