import 'dart:io';

import 'package:coreflow/core/storage/token_storage.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/routing/app_routinf.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler — MUST be a top-level function,
/// not a class method, for Firebase to invoke it from a background isolate.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM background message: ${message.messageId}');
}

/// Handles FCM push notifications: token management, foreground display,
/// and notification tap navigation.
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AuthRepository _authRepository = AuthRepository();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Register background handler FIRST
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('FCM permission status: ${settings.authorizationStatus}');

    // Enable foreground notification display on Android
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set up local notifications for foreground display
    await _setupLocalNotifications();

    // Get and save FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      await TokenStorage.saveFcmToken(token);
      debugPrint('FCM token: ${token.substring(0, 30)}...');
    } else {
      debugPrint('FCM token is NULL — push will not work');
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM token refreshed');
      await TokenStorage.saveFcmToken(newToken);
      if (await TokenStorage.hasValidToken()) {
        await _registerWithBackend(newToken);
      }
    });

    // Foreground messages — show as local notification
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background/terminated notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // App opened from terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Register the saved FCM token with the backend. Call after login.
  Future<void> registerTokenWithBackend() async {
    final fcmToken = await TokenStorage.getFcmToken();
    if (fcmToken != null) {
      debugPrint('Registering FCM token with backend...');
      final success = await _registerWithBackend(fcmToken);
      debugPrint('FCM token registration: ${success ? 'SUCCESS' : 'FAILED'}');
    } else {
      debugPrint('No FCM token to register — skipping');
    }
  }

  /// Deregister the FCM token from the backend. Call before logout.
  Future<void> deregisterToken() async {
    final fcmToken = await TokenStorage.getFcmToken();
    if (fcmToken != null) {
      await _authRepository.deregisterDeviceToken(fcmToken);
    }
  }

  Future<bool> _registerWithBackend(String fcmToken) async {
    final deviceType = Platform.isAndroid ? 'ANDROID' : 'IOS';
    return await _authRepository.registerDeviceToken(fcmToken, deviceType);
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _navigateToRoute(payload);
        }
      },
    );

    // Create the notification channel for Android
    const channel = AndroidNotificationChannel(
      'coreflow_notifications',
      'CoreFlow Notifications',
      description: 'Push notifications from CoreFlow',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM foreground message received: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'coreflow_notifications',
          'CoreFlow Notifications',
          channelDescription: 'Push notifications from CoreFlow',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['actionUrl'] ?? '',
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final actionUrl = message.data['actionUrl'];
    if (actionUrl != null && actionUrl.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateToRoute(actionUrl);
      });
    }
  }

  void _navigateToRoute(String route) {
    try {
      router.go(route);
    } catch (e) {
      debugPrint('Push notification navigation error: $e');
    }
  }
}
