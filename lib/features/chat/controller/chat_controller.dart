import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/storage_repository_provider.dart';
import '../../../../core/utils.dart';
import '../../../model/chat_contact.dart';
import '../../../model/message.dart';
import '../../auth/controller/auth_controller.dart';
import '../repository/chat_repo.dart';
// y
final chatControllerProvider = Provider((ref) {
  final chatRepo = ref.watch(chatRepoProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return ChatController(
    chatRepo: chatRepo,
    storageRepository: storageRepository,
    ref: ref,
  );
});
class ChatController{
  final ChatRepo _chatRepo;
  final Ref _ref;
  final StorageRepository _storageRepository;
  Stream<List<ChatContact>> chatContacts() {
    return _chatRepo.getChatContacts();
  }
  Stream<List<Message>> chatStream(String receiverUserId) {
    return _chatRepo.getChatStream(receiverUserId);
  }

  ChatController({
    required ChatRepo chatRepo,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _chatRepo = chatRepo,
        _ref = ref,
        _storageRepository = storageRepository;

  void sendTextMessage(
      BuildContext context, String message, String receiverUserId) async {
    try {
      _ref.read(getCurrentUserDataProvider).whenData((user) {
        _chatRepo.sendTextMessage(
          message: message,
          senderUser: user!,
          receiverUserId: receiverUserId,
          context: context,
        );
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
