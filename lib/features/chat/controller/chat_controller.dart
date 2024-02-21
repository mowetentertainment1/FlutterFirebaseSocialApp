import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void sendTextMessage(
      BuildContext context, String message, String receiverUserId) async {
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
    final imageSave= await _storageRepository.storeFile(
      path:'chat/$receiverUserId/',
      file: file,
      id: messageEnum.type,
    );
    final imageUrl = imageSave.fold((l) => '', (r) => r);
    state = false;

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
  }
}
