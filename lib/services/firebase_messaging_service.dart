import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  FirebaseMessaging? _messaging;

  Future<void> init() async {
    _messaging = FirebaseMessaging.instance;

    await _requestPermission();
    _registerHandlers();
  }

  Future<void> _requestPermission() async {
    await _messaging!.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<String?> getFcmToken() async {
    return await _messaging!.getToken();
  }

  void _registerHandlers() {
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedFromNotification);
  }

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('📩 Foreground: ${message.notification?.title}');
  }

  void _onOpenedFromNotification(RemoteMessage message) {
    debugPrint('🚀 Opened from notification');
  }
}
