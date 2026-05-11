import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:coreflow/core/storage/token_storage.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/firebase_options.dart';
import 'package:coreflow/routing/app_routinf.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DartPluginRegistrant.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await _applyBadgeCountFromData(message.data);
  debugPrint('FCM background message: ${message.messageId}');
}

Future<void> _applyBadgeCountFromData(Map<String, dynamic> data) async {
  final badgeCount = _parseBadgeCount(data);
  if (badgeCount != null) {
    await _setLauncherBadge(badgeCount);
  }
}

Future<void> _setLauncherBadge(int count) async {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
    return;
  }

  final safeCount = count < 0 ? 0 : count;
  try {
    final supported = await AppBadgePlus.isSupported();
    if (supported || Platform.isIOS || Platform.isMacOS) {
      await AppBadgePlus.updateBadge(safeCount);
    }
  } catch (e) {
    debugPrint('Launcher badge update failed: $e');
  }
}

int? _parseBadgeCount(Map<String, dynamic> data) {
  const keys = ['badge', 'badgeCount', 'unreadCount', 'notificationCount'];

  for (final key in keys) {
    final value = data[key];
    if (value == null) continue;
    if (value is int) return value;
    if (value is num) return value.round();
    final parsed = int.tryParse(value.toString().trim());
    if (parsed != null) return parsed;
  }

  return null;
}

int? _parseIntValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString().trim());
}

String? _firstNonEmpty(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key]?.toString().trim();
    if (value != null && value.isNotEmpty && value.toLowerCase() != 'null') {
      return value;
    }
  }
  return null;
}

class PushNotificationService {
  static const String _channelId = 'coreflow_notifications_v2';
  static const String _channelName = 'CoreFlow Notifications';
  static const String _channelDescription = 'Push notifications from CoreFlow';

  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AuthRepository _authRepository = AuthRepository();

  bool _initialized = false;
  int _lastBadgeCount = 0;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _messaging.setAutoInitEnabled(true);

    await _setupLocalNotifications();
    await _requestNotificationPermissions();
    await _saveCurrentToken();

    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM token refreshed');
      await TokenStorage.saveFcmToken(newToken);
      if (await TokenStorage.hasValidToken()) {
        await _registerWithBackend(newToken);
        await syncBadgeFromBackend();
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      unawaited(_handleForegroundMessage(message));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      unawaited(_handleNotificationTap(message));
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      unawaited(_handleNotificationTap(initialMessage));
    }

    await syncBadgeFromBackend();
  }

  Future<void> registerTokenWithBackend() async {
    var fcmToken = await TokenStorage.getFcmToken();
    if (fcmToken == null || fcmToken.isEmpty) {
      await _saveCurrentToken();
      fcmToken = await TokenStorage.getFcmToken();
    }
    if (fcmToken != null) {
      debugPrint('Registering FCM token with backend...');
      final success = await _registerWithBackend(fcmToken);
      debugPrint('FCM token registration: ${success ? 'SUCCESS' : 'FAILED'}');
      if (success) {
        await syncBadgeFromBackend();
      }
    } else {
      debugPrint('No FCM token to register, skipping');
    }
  }

  Future<void> deregisterToken() async {
    final fcmToken = await TokenStorage.getFcmToken();
    if (fcmToken != null) {
      await _authRepository.deregisterDeviceToken(fcmToken);
    }
    await clearBadge();
  }

  Future<void> setBadgeCount(int count) async {
    _lastBadgeCount = count < 0 ? 0 : count;
    await _setLauncherBadge(_lastBadgeCount);
  }

  Future<void> clearBadge() => setBadgeCount(0);

  Future<int?> syncBadgeFromBackend({int? companyId}) async {
    if (!await TokenStorage.hasValidToken()) return null;

    final resolvedCompanyId = companyId ?? await _storedCompanyId();
    if (resolvedCompanyId == null) return null;

    final unreadCount = await _authRepository.getUnreadNotificationCount(
      resolvedCompanyId,
    );
    await setBadgeCount(unreadCount);
    return unreadCount;
  }

  Future<bool> _registerWithBackend(String fcmToken) async {
    final deviceType = Platform.isAndroid ? 'ANDROID' : 'IOS';
    return _authRepository.registerDeviceToken(fcmToken, deviceType);
  }

  Future<void> _saveCurrentToken() async {
    const maxAttempts = 4;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) {
          await TokenStorage.saveFcmToken(token);
          final previewLength = token.length < 30 ? token.length : 30;
          debugPrint('FCM token: ${token.substring(0, previewLength)}...');
          return;
        }
        debugPrint('FCM token is null, push may not work on this device yet');
      } catch (e) {
        final message = e.toString().toUpperCase();
        final isRetryable =
            message.contains('SERVICE_NOT_AVAILABLE') ||
            message.contains('INTERNAL_SERVER_ERROR') ||
            message.contains('IOEXCEPTION');
        debugPrint('FCM getToken attempt $attempt failed: $e');
        if (!isRetryable || attempt == maxAttempts) {
          debugPrint(
            'FCM token fetch failed after $attempt attempts. The app will continue and retry later.',
          );
          return;
        }
      }

      if (attempt < maxAttempts) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
  }

  Future<void> _requestNotificationPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('FCM permission status: ${settings.authorizationStatus}');

    if (Platform.isAndroid) {
      final granted = await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      debugPrint('Android notification permission granted: $granted');
    } else if (Platform.isIOS) {
      final granted = await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      debugPrint('iOS notification permission granted: $granted');
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          unawaited(_handleLocalNotificationPayload(payload));
        }
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint(
      'FCM foreground message received: ${message.notification?.title ?? message.data['title']}',
    );

    final badgeCount = await _updateBadgeForMessage(message);
    final notification = message.notification;
    final title =
        notification?.title ??
        _firstNonEmpty(message.data, ['title', 'notificationTitle', 'subject']);
    final body =
        notification?.body ??
        _firstNonEmpty(message.data, ['body', 'message', 'notificationBody']);

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          channelShowBadge: true,
          number: badgeCount ?? _lastBadgeCount,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: badgeCount ?? _lastBadgeCount,
        ),
      ),
      payload: _buildLocalPayload(message),
    );
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    await _markNotificationReadFromData(message.data);
    final companyId = _companyIdFromData(message.data);
    await syncBadgeFromBackend(companyId: companyId);

    final actionUrl = message.data['actionUrl'];
    if (actionUrl != null && actionUrl.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateToRoute(actionUrl);
      });
    }
  }

  Future<int?> _updateBadgeForMessage(RemoteMessage message) async {
    final badgeCount = _parseBadgeCount(message.data);
    if (badgeCount != null) {
      await setBadgeCount(badgeCount);
      return badgeCount;
    }

    return syncBadgeFromBackend(companyId: _companyIdFromData(message.data));
  }

  String _buildLocalPayload(RemoteMessage message) {
    return jsonEncode({
      'actionUrl': message.data['actionUrl'] ?? '',
      'notificationId': message.data['notificationId'] ?? '',
      'toCompanyId': message.data['toCompanyId'] ?? '',
      'companyId': message.data['companyId'] ?? '',
    });
  }

  Future<void> _handleLocalNotificationPayload(String payload) async {
    String route = payload;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        await _markNotificationReadFromData(decoded);
        await syncBadgeFromBackend(companyId: _companyIdFromData(decoded));
        route = decoded['actionUrl']?.toString() ?? '';
      }
    } catch (_) {
      // Older payloads were plain routes.
    }

    if (route.isNotEmpty) {
      _navigateToRoute(route);
    }
  }

  Future<void> _markNotificationReadFromData(Map<String, dynamic> data) async {
    final notificationId = _parseIntValue(data['notificationId']);
    final companyId = _companyIdFromData(data);
    if (notificationId == null || companyId == null) return;
    if (!await TokenStorage.hasValidToken()) return;

    await _authRepository.markNotificationRead(companyId, notificationId);
  }

  int? _companyIdFromData(Map<String, dynamic> data) {
    return _parseIntValue(data['toCompanyId']) ??
        _parseIntValue(data['companyId']);
  }

  Future<int?> _storedCompanyId() async {
    final data = await TokenStorage.getFullAuthData();
    return _parseIntValue(data?['companyId']);
  }

  void _navigateToRoute(String route) {
    try {
      router.go(route);
    } catch (e) {
      debugPrint('Push notification navigation error: $e');
    }
  }
}
