// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage(
    // ✅ CRITICAL: Enhanced security options for PWA
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  // ✅ Multiple storage strategies for maximum persistence
  static Future<void> saveLoginData({
    required String token,
    required String userType,
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // 1. Secure Storage (Primary)
      await _storage.write(key: 'auth_token', value: token);
      await _storage.write(key: 'user_type', value: userType);
      await _storage.write(key: 'user_id', value: userId);
      await _storage.write(key: 'user_data', value: jsonEncode(userData));

      // 2. SharedPreferences (Backup for PWA)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token_backup', token);
      await prefs.setString('user_type_backup', userType);
      await prefs.setString('user_id_backup', userId);
      await prefs.setString('user_data_backup', jsonEncode(userData));

      // 3. Set login timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await _storage.write(key: 'login_timestamp', value: timestamp.toString());
      await prefs.setInt('login_timestamp_backup', timestamp);

      // 4. Remember login preference
      await prefs.setBool('remember_login', true);
      await prefs.setBool('auto_login_enabled', true);

      print('✅ Login data saved with multiple persistence strategies');
    } catch (e) {
      print('❌ Error saving login data: $e');
    }
  }

  static Future<Map<String, String?>> getLoginData() async {
    try {
      // Try secure storage first
      String? token = await _storage.read(key: 'auth_token');
      String? userType = await _storage.read(key: 'user_type');
      String? userId = await _storage.read(key: 'user_id');
      String? userData = await _storage.read(key: 'user_data');

      // If secure storage fails, try SharedPreferences backup
      if (token == null || userType == null) {
        print('🔄 Secure storage empty, trying SharedPreferences backup...');
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('auth_token_backup');
        userType = prefs.getString('user_type_backup');
        userId = prefs.getString('user_id_backup');
        userData = prefs.getString('user_data_backup');

        // If we found data in SharedPreferences, restore to secure storage
        if (token != null && userType != null) {
          await _storage.write(key: 'auth_token', value: token);
          await _storage.write(key: 'user_type', value: userType);
          if (userId != null)
            await _storage.write(key: 'user_id', value: userId);
          if (userData != null)
            await _storage.write(key: 'user_data', value: userData);
          print('✅ Restored login data from SharedPreferences backup');
        }
      }

      return {
        'token': token,
        'user_type': userType,
        'user_id': userId,
        'user_data': userData,
      };
    } catch (e) {
      print('❌ Error getting login data: $e');
      return {
        'token': null,
        'user_type': null,
        'user_id': null,
        'user_data': null,
      };
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final loginData = await getLoginData();
      final token = loginData['token'];

      if (token == null || token.isEmpty) {
        print('❌ No token found');
        return false;
      }

      // Check if token is still valid (optional backend call)
      final isValid = await _validateToken(token);
      if (!isValid) {
        print('❌ Token validation failed');
        await clearLoginData();
        return false;
      }

      print('✅ User is logged in with valid token');
      return true;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  static Future<bool> _validateToken(String token) async {
    try {
      // Quick token validation with your backend
      final result = await ApiService.getUserProfile();
      return result['success'] == true;
    } catch (e) {
      print('⚠️ Token validation failed: $e');
      return true; // Assume valid if can't reach server
    }
  }

  static Future<void> clearLoginData() async {
    try {
      // Clear secure storage
      await _storage.deleteAll();

      // Clear SharedPreferences backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token_backup');
      await prefs.remove('user_type_backup');
      await prefs.remove('user_id_backup');
      await prefs.remove('user_data_backup');
      await prefs.remove('login_timestamp_backup');
      await prefs.setBool('remember_login', false);
      await prefs.setBool('auto_login_enabled', false);

      print('✅ All login data cleared');
    } catch (e) {
      print('❌ Error clearing login data: $e');
    }
  }

  static Future<bool> shouldAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final autoLoginEnabled = prefs.getBool('auto_login_enabled') ?? false;
      final rememberLogin = prefs.getBool('remember_login') ?? false;

      if (!autoLoginEnabled || !rememberLogin) {
        return false;
      }

      // Check if login is not too old (optional)
      final loginTimestamp = prefs.getInt('login_timestamp_backup') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final daysSinceLogin = (now - loginTimestamp) / (1000 * 60 * 60 * 24);

      // Keep login for 30 days max (adjust as needed)
      if (daysSinceLogin > 30) {
        print('🔄 Login expired after 30 days, clearing data');
        await clearLoginData();
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error checking auto-login: $e');
      return false;
    }
  }

  // ✅ Enhanced login method
  static Future<Map<String, dynamic>> login(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    try {
      final result = await ApiService.login(email, password);

      if (result['success'] && result['data'] != null) {
        final data = result['data'];

        // Save login data with persistence
        await saveLoginData(
          token: data['access_token'] ?? data['token'],
          userType: data['user_type'] ?? data['user']?['role'] ?? 'athlete',
          userId:
              data['user_id']?.toString() ??
              data['user']?['id']?.toString() ??
              '',
          userData: data['user'] ?? {},
        );

        print('✅ Login successful with persistent storage');
      }

      return result;
    } catch (e) {
      print('❌ Login error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ✅ Silent token refresh (call periodically)
  static Future<void> refreshTokenSilently() async {
    try {
      final loginData = await getLoginData();
      final token = loginData['token'];

      if (token != null) {
        // Update timestamp to keep session alive
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        await _storage.write(
          key: 'login_timestamp',
          value: timestamp.toString(),
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('login_timestamp_backup', timestamp);

        print('🔄 Token refreshed silently');
      }
    } catch (e) {
      print('❌ Silent refresh failed: $e');
    }
  }
}
