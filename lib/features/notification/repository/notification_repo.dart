import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:untitled/model/notification_model.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/type_defs.dart';
import '../../chat/screens/chat_screen.dart';

final notificationRepoProvider = Provider((ref) {
  return NotificationRepo(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
      firebaseMessaging: FirebaseMessaging.instance,
      flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin());
});

class NotificationRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);
  NotificationRepo(
      {required FirebaseFirestore firestore,
      required FirebaseAuth auth,
      required FirebaseMessaging firebaseMessaging,
      required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin})
      : _firestore = firestore,
        _auth = auth,
        _firebaseMessaging = firebaseMessaging,
        _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;
  FutureVoid sendNotification({
    required NotificationModel notification,
  }) async {
    try {
      return right(
        _users
            .doc(notification.uid)
            .collection(FirebaseConstants.notificationsCollection)
            .doc(notification.id)
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
        .map((event) =>
            event.docs.map((e) => NotificationModel.fromMap(e.data())).toList());
  }

  void markAsRead(String id) {
    _users
        .doc(_auth.currentUser!.uid)
        .collection(FirebaseConstants.notificationsCollection)
        .doc(id)
        .update({'isRead': true});
  }

  void deleteAllNotifications() {
    _users
        .doc(_auth.currentUser!.uid)
        .collection(FirebaseConstants.notificationsCollection)
        .get()
        .then((value) => value.docs.forEach((element) {
              element.reference.delete();
            }));
  }

  void readAllNotifications() {
    _users
        .doc(_auth.currentUser!.uid)
        .collection(FirebaseConstants.notificationsCollection)
        .get()
        .then((value) => value.docs.forEach((element) {
              element.reference.update({'isRead': true});
            }));
  }

  Future<void> checkNewNotifications(String lastCheckedTimestamp) async {
    QuerySnapshot querySnapshot = await _users
        .doc(_auth.currentUser!.uid)
        .collection(FirebaseConstants.notificationsCollection)
        .where('createAt', isGreaterThan: lastCheckedTimestamp)
        .get();
    querySnapshot.docs.forEach((doc) {});
  }

  Stream<int> getUnreadNotificationsCount() {
    return _users
        .doc(_auth.currentUser!.uid)
        .collection(FirebaseConstants.notificationsCollection)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((event) => event.docs.length);
  }

  void requestNotificationPermission() async {
    await _firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
  }

  Future<String> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    return token!;
  }

  void isTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((event) {
      event.toString();
      print('isTokenRefresh: $event');
    });
  }

  void initLocalNotification(BuildContext context, RemoteMessage message) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitializationSettings = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: iosInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
      handleMessages(context, message);
    });
  }

  void onMessage(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        showNotification(
            title: message.notification!.title!, body: message.notification!.body!);
      } else {
        showNotification(
            title: message.notification!.title!, body: message.notification!.body!);
      }
    });
  }

  Future<void> showNotification({required String title, required String body}) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      Random.secure().nextInt(10000).toString(),
      'Notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      ticker: 'ticker',
      playSound: true,
    );
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void handleMessages(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ChatScreen()));
    }
  }
  Future<void> setupInteractedMessage(BuildContext context) async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      handleMessages(context, initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessages(context, message);
    });
  }
}
