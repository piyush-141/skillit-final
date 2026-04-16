import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyToken = "auth_token";
  static const String _keyUserName = "user_name";
  static const String _keyUserEmail = "user_email";
  static const String _keyUserDomain = "user_domain";

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    return token != null && token.isNotEmpty;
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Save auth data
  static Future<void> saveAuthData({
    required String token,
    required String name,
    required String email,
    String? domain,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserEmail, email);
    if (domain != null) await prefs.setString(_keyUserDomain, domain);
  }

  // Save partial user data
  static Future<void> updateUserLocalData({
    String? name,
    String? domain,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(_keyUserName, name);
    if (domain != null) await prefs.setString(_keyUserDomain, domain);
  }

  // Get cached user info
  static Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyUserName) ?? 'User',
      'email': prefs.getString(_keyUserEmail) ?? '',
      'domain': prefs.getString(_keyUserDomain) ?? 'Not Set',
    };
  }

  // Clear auth data (Logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
