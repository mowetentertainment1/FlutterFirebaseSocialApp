import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/features/chat/repository/community_chat_repo.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/storage_repository_provider.dart';
import '../../../../core/utils.dart';
import '../../../core/enums/message_enum.dart';
import '../../../model/community_chat_model.dart';
import '../../../model/message_model.dart';
import '../../auth/controller/auth_controller.dart';

final communityChatControllerProvider =
    StateNotifierProvider<CommunityChatController, bool>((ref) {
  final communityChatRepo = ref.watch(communityChatRepoProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityChatController(
    communityChatRepo: communityChatRepo,
    ref: ref,
    storageRepository: storageRepository,
  );
});
final communityChatStream =
    StreamProvider.family<List<MessageModel>, String>((ref, receiverUserId) {
  return ref.read(communityChatControllerProvider.notifier).getChatStream(receiverUserId);
});

class CommunityChatController extends StateNotifier<bool> {
  final CommunityChatRepo _communityChatRepo;
  final Ref _ref;
  final StorageRepository _storageRepository;
  Stream<List<CommunityChatModel>> chatContacts() {
    return _communityChatRepo.getChatGroups();
  }

  CommunityChatController({
    required CommunityChatRepo communityChatRepo,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _communityChatRepo = communityChatRepo,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void sendTextMessage(
      BuildContext context, String message, String receiverCommunityId) async {
    state = true;
    try {
      _ref.read(getCurrentUserDataProvider).whenData(
            (value) => _communityChatRepo.sendTextMessage(
              message: message,
              senderUser: value,
              context: context,
              receiverCommunityId: receiverCommunityId,
            ),
          );
      state = false;
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Stream<List<MessageModel>> getChatStream(String receiverUserId) {
    return _communityChatRepo.getChatStream(receiverUserId);
  }

  Future<void> sendFileMessage(
    BuildContext context,
    File file,
    String receiverUserId,
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
              (value) => _communityChatRepo.sendFileMessage(
                context: context,
                file: file,
                receiverUserId: receiverUserId,
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
              (value) => _communityChatRepo.sendFileMessage(
                context: context,
                file: file,
                receiverUserId: receiverUserId,
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
              (value) => _communityChatRepo.sendFileMessage(
                context: context,
                file: file,
                receiverUserId: receiverUserId,
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
    final res = await _communityChatRepo.deleteChat(receiverUserId);
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
