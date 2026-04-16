import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'resume_service.dart';

/// Persists a user's resume as a JSON string inside SharedPreferences.
/// No local file access — fully works in sandboxed / web environments.
class ResumePersistenceService {
  static const String _key = 'saved_resume_json';

  // ── Save ──────────────────────────────────────────────────────────────────

  static Future<void> saveResumeData(ResumeData data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(data.toJson());
    await prefs.setString(_key, json);
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  static Future<ResumeData?> loadResumeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      if (json == null || json.isEmpty) return null;
      final Map<String, dynamic> map = jsonDecode(json) as Map<String, dynamic>;
      return ResumeData.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Future<bool> hasResume() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    return json != null && json.isNotEmpty;
  }

  static Future<void> clearResume() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
