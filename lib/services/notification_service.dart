import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'pocketbase_service.dart';
import '../router/app_router.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (!kIsWeb) {
      // 1. Initialize Local Notifications for Foreground
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
      
      await _localNotif.initialize(
        initializationSettings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          if (details.payload != null) {
            final data = jsonDecode(details.payload!);
            _handleRouting(data);
          }
        },
      );
    }

    // 2. Request Permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Background Handler (Top Level or Static)
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }

    // 4. Foreground Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // 5. App Opened from Notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleRouting(message.data);
    });

    // 6. Initial Message (Terminated State)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleRouting(initialMessage.data);
    }

    // 7. Token Management
    _fcm.onTokenRefresh.listen(_saveTokenToBackend);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && !kIsWeb) {
      await _localNotif.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleRouting(Map<String, dynamic> data) {
    final type = data['type'];
    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context == null) return;

    switch (type) {
      case 'new_message':
      case 'new_offer':
      case 'offer_declined':
        if (data['chatId'] != null) context.push('/chat/${data['chatId']}');
        break;
      case 'offer_accepted':
      case 'handover_ready':
        if (data['txnId'] != null) context.push('/transaction/${data['txnId']}');
        break;
      case 'transaction_complete':
        if (data['txnId'] != null) context.push('/transaction/${data['txnId']}/review');
        break;
      case 'new_review':
        if (data['userId'] != null) context.push('/seller/${data['userId']}');
        break;
      case 'price_drop':
      case 'book_sold':
        if (data['bookId'] != null) context.push('/book/${data['bookId']}');
        break;
      case 'badge_earned':
        context.push('/badges');
        break;
      default:
        context.push('/notifications');
    }
  }

  Future<void> updateToken() async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToBackend(token);
    }
  }

  Future<void> _saveTokenToBackend(String token) async {
    final pb = PocketBaseService.instance.pb;
    if (pb.authStore.isValid) {
      try {
        await pb.collection('users').update(pb.authStore.record!.id, body: {
          'fcm_token': token,
        });
        debugPrint('FCM Token updated');
      } catch (e) {
        debugPrint('Error updating FCM Token: $e');
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kIsWeb) return;
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}
