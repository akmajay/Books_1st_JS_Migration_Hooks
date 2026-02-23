import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/env.dart';
import '../models/user_model.dart';
import 'pocketbase_service.dart';

class AuthService extends ChangeNotifier {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// PocketBase client instance
  PocketBase get pb => PocketBaseService.instance.pb;
  PocketBase get _pb => pb;

  /// Check if user is currently authenticated
  bool get isLoggedIn => _pb.authStore.isValid;

  /// Get current authenticated user as UserModel
  UserModel? get currentUser {
    if (!isLoggedIn) return null;
    final model = _pb.authStore.record;
    if (model is RecordModel) {
      return UserModel.fromJson(model.toJson());
    }
    return null;
  }
  
  /// Google Sign-In -> PocketBase OAuth
  Future<UserModel> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign-In (isWeb: $kIsWeb)');
      debugPrint('Redirect URI: ${Env.pocketbaseUrl}/api/collections/users/auth-with-oauth2');
      
      final authData = await _pb.collection('users').authWithOAuth2(
        'google',
        (Uri url) async {
          debugPrint('Launching Auth URL: $url');
          if (await canLaunchUrl(url)) {
            // Use externalApplication to ensure a new browser tab/window is used
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $url';
          }
        },
      );
      
      debugPrint('Auth successful! User: ${authData.record.id}');
      notifyListeners(); // Ensure UI updates
      return UserModel.fromJson(authData.record.toJson());
    } on ClientException catch (e) {
      debugPrint('PocketBase OAuth Error: $e');
      debugPrint('Status Code: ${e.statusCode}');
      debugPrint('Response Body: ${e.response}');
      rethrow;
    } catch (e) {
      debugPrint('Google Sign-In General Error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _pb.authStore.clear();
    notifyListeners();
  }

  /// Check if auth token is still valid
  Future<bool> isTokenValid() async {
    if (!isLoggedIn) return false;
    try {
      // Refresh auth token to check validity
      await _pb.collection('users').authRefresh();
      return true;
    } catch (_) {
      // Token invalid or expired
      _pb.authStore.clear();
      return false;
    }
  }

  /// Check if current user is banned
  Future<bool> isUserBanned() async {
    final user = currentUser;
    if (user != null && user.isBanned) {
      await signOut();
      return true;
    }
    return false;
  }

  /// Get fresh user data from server
  Future<UserModel?> refreshUser() async {
    if (!isLoggedIn) return null;
    try {
      final record = await _pb.collection('users').authRefresh();
      return UserModel.fromJson(record.record.toJson());
    } catch (e) {
      debugPrint('Failed to refresh user data: $e');
      return null;
    }
  }

  /// Update user profile data
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    if (!isLoggedIn) throw 'User not logged in';
    final userId = currentUser?.id;
    if (userId == null) throw 'User ID not found';

    try {
      final record = await _pb.collection('users').update(userId, body: data);
      return UserModel.fromJson(record.toJson());
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  /// Check if a phone number is already registered to another user
  Future<bool> isPhoneRegistered(String phone) async {
    try {
      final result = await _pb.collection('users').getList(
        filter: 'phone = "$phone"',
      );
      
      // If found and it's not the current user
      if (result.items.isNotEmpty) {
        final existingId = result.items.first.id;
        return existingId != currentUser?.id;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Register FCM token for notifications
  Future<void> registerFcmToken() async {
    if (!isLoggedIn) return;
    try {
      final fcm = FirebaseMessaging.instance;
      final token = await fcm.getToken();
      if (token != null) {
        await updateProfile({'fcm_token': token});
      }
    } catch (e) {
      // Non-critical failure
      debugPrint('FCM registration failed: $e');
    }
  }

  /// Find user ID by referral code
  Future<String?> findUserIdByReferralCode(String code) async {
    try {
      final result = await _pb.collection('users').getFirstListItem(
        'referral_code = "$code"',
      );
      return result.id;
    } catch (e) {
      debugPrint('Referral code not found: $code');
      return null;
    }
  }
}
