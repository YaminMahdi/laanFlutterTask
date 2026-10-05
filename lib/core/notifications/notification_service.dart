import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef NotificationTapCallback = void Function(String? payload);

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationTapCallback? onNotificationTapped;

  static const String progressChannelId = 'laan_transfer_progress';
  static const String progressChannelName = 'Transfer Progress';
  static const String progressChannelDescription =
      'Shows ongoing file upload and download progress.';

  static const String completionChannelId = 'laan_transfer_completed';
  static const String completionChannelName = 'Transfer Completed';
  static const String completionChannelDescription =
      'Shows notifications when transfers finish.';

  bool _isInitialized = false;

  Future<void> initialize({
    NotificationTapCallback? onNotificationTapped,
  }) async {
    if (_isInitialized) return;
    this.onNotificationTapped = onNotificationTapped;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        this.onNotificationTapped?.call(response.payload);
      },
    );

    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          progressChannelId,
          progressChannelName,
          description: progressChannelDescription,
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
          showBadge: false,
        ),
      );

      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          completionChannelId,
          completionChannelName,
          description: completionChannelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ),
      );

      // Request runtime notification permission on Android 13+
      await androidImplementation?.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  int _getNotificationId(String transferId) {
    return transferId.hashCode.abs() % 100000;
  }

  Future<void> showProgressNotification({
    required String id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
  }) async {
    if (!_isInitialized) return;

    final notificationId = _getNotificationId(id);
    final androidDetails = AndroidNotificationDetails(
      progressChannelId,
      progressChannelName,
      channelDescription: progressChannelDescription,
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      ongoing: true,
      autoCancel: false,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: id,
    );
  }

  Future<void> showCompletionNotification({
    required String id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) return;

    final notificationId = _getNotificationId(id);
    // Dismiss ongoing progress notification
    await cancelNotification(id);

    const androidDetails = AndroidNotificationDetails(
      completionChannelId,
      completionChannelName,
      channelDescription: completionChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      id: notificationId + 500000,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload ?? id,
    );
  }

  Future<void> showErrorNotification({
    required String id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) return;

    await cancelNotification(id);
    final notificationId = _getNotificationId(id);

    const androidDetails = AndroidNotificationDetails(
      completionChannelId,
      completionChannelName,
      channelDescription: completionChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: false,
      autoCancel: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      id: notificationId + 500000,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: id,
    );
  }

  Future<void> cancelNotification(String id) async {
    if (!_isInitialized) return;
    final notificationId = _getNotificationId(id);
    await _notificationsPlugin.cancel(id: notificationId);
  }

  Future<void> cancelAll() async {
    if (!_isInitialized) return;
    await _notificationsPlugin.cancelAll();
  }
}
