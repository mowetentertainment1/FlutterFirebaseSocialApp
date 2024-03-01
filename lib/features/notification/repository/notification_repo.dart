import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/core/enums/notification_enums.dart';
import 'package:untitled/model/notification_model.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/type_defs.dart';

final notificationRepoProvider = Provider((ref) {
  return NotificationRepo(
      firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance);
});

class NotificationRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);
  NotificationRepo({required FirebaseFirestore firestore, required FirebaseAuth auth})
      : _firestore = firestore,
        _auth = auth;
  FutureVoid sendNotification({
    required NotificationModel notification,
  }) async {
    try {
      return right( _users
          .doc(notification.id)
          .collection(FirebaseConstants.notificationsCollection)
          .doc(notification.name)
          .set(notification.toMap()),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  Stream<List<NotificationModel>> getNotifications() {
    return _users
        .doc(_auth.currentUser!.uid)
        .collection(FirebaseConstants.notificationsCollection)
        .snapshots()
        .map((event) => event.docs
            .map((e) => NotificationModel.fromMap(e.data()))
            .toList());
  }
}
