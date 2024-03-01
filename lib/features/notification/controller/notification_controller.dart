import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/features/notification/repository/notification_repo.dart';
import 'package:untitled/model/notification_model.dart';

final notificationController = StateNotifierProvider<NotificationController, bool>((ref) {
  final notificationRepo = ref.watch(notificationRepoProvider);
  return NotificationController(
    notificationRepo: notificationRepo,
    ref: ref,
  );
});
final notificationStream = StreamProvider<List<NotificationModel>>((ref) {
  return ref.read(notificationController.notifier).getNotifications();
});

class NotificationController extends StateNotifier<bool> {
  final NotificationRepo _notificationRepo;
  final Ref _ref;
  Stream<List<NotificationModel>> getNotifications() {
    return _notificationRepo.getNotifications();
  }

  NotificationController({
    required NotificationRepo notificationRepo,
    required Ref ref,
  })  : _notificationRepo = notificationRepo,
        _ref = ref,
        super(false);
}
