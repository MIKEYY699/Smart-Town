import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../firebase_options.dart';
import '../routes/app_routes.dart';

/// Push notifications through Firebase Cloud Messaging.
///
/// The phone's FCM token is saved in the `device_tokens` table while a user
/// is logged in. A Supabase Edge Function sends a push to those tokens
/// whenever a row is added to `notifications`.
///
/// This uses the classic FCM token (getToken / onTokenRefresh), which the
/// Edge Function sends to with the FCM HTTP v1 API. Those calls are marked
/// deprecated in firebase_messaging 17 in favour of register() /
/// onRegistered, which hand out an installation ID for a different send API.
// ignore_for_file: deprecated_member_use
class PushService {
  PushService._();

  static bool _ready = false;

  static Future<void> init() async {
    // Web push needs a service worker and VAPID key. Not set up yet.
    if (kIsWeb) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // The app works without push, so never block startup on it.
      debugPrint('Push disabled: $e');
      return;
    }
    _ready = true;

    final messaging = FirebaseMessaging.instance;
    final auth = Supabase.instance.client.auth;

    auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (data.session != null &&
          (event == AuthChangeEvent.initialSession ||
              event == AuthChangeEvent.signedIn)) {
        _register();
      }
    });

    messaging.onTokenRefresh.listen((token) {
      if (auth.currentSession != null) _saveToken(token);
    });

    // Tapped while the app was in the background.
    FirebaseMessaging.onMessageOpenedApp.listen(_openFromMessage);

    // Tapped while the app was closed. Wait for the router to be built.
    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openFromMessage(initial),
      );
    }
  }

  static Future<void> _register() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _saveToken(token);
    } catch (e) {
      debugPrint('Could not register for push: $e');
    }
  }

  static Future<void> _saveToken(String token) async {
    try {
      await Supabase.instance.client.rpc(
        'register_device_token',
        params: {'p_token': token, 'p_platform': defaultTargetPlatform.name},
      );
    } catch (e) {
      debugPrint('Could not save push token: $e');
    }
  }

  /// Stops pushes to this phone. Call before signing out, while the
  /// session is still valid.
  static Future<void> unregister() async {
    if (!_ready) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await Supabase.instance.client
          .from('device_tokens')
          .delete()
          .eq('token', token)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Signing out must still work when offline.
    }
  }

  static Future<void> _openFromMessage(RemoteMessage message) async {
    final id = message.data['notification_id'] as String?;
    if (id != null) {
      try {
        await Supabase.instance.client
            .from('notifications')
            .update({'read_at': DateTime.now().toUtc().toIso8601String()})
            .eq('id', id);
      } catch (_) {
        // Opening the screen still works even if marking as read fails.
      }
    }
    final type = message.data['type'] as String? ?? '';
    if (!openTarget(appRouter, type)) {
      appRouter.push(AppRoutes.notificationsScreen);
    }
  }

  /// Goes to the screen that belongs to a notification type.
  /// Returns false when the type has no screen of its own.
  static bool openTarget(GoRouter router, String type) {
    if (type == 'new_request' || type == 'cancelled' || type == 'review') {
      router.push(AppRoutes.providerDashboardScreen);
      return true;
    }
    if (type == 'status') {
      router.go(AppRoutes.myRequestsScreen);
      return true;
    }
    return false;
  }
}
