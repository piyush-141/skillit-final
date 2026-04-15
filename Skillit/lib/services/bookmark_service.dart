import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _keyInternships = 'saved_internships';
  static const String _keyHackathons = 'saved_hackathons';

  // ✅ GET SAVED INTERNSHIP IDs
  static Future<List<String>> getSavedInternshipIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyInternships) ?? [];
  }

  // ✅ TOGGLE SAVED INTERNSHIP
  static Future<bool> toggleInternship(String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList(_keyInternships) ?? [];
    
    bool isSaved;
    if (saved.contains(title)) {
      saved.remove(title);
      isSaved = false;
    } else {
      saved.add(title);
      isSaved = true;
    }
    
    await prefs.setStringList(_keyInternships, saved);
    return isSaved;
  }

  // ✅ CHECK IF INTERNSHIP IS SAVED
  static Future<bool> isInternshipSaved(String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList(_keyInternships) ?? [];
    return saved.contains(title);
  }

  // ✅ GET SAVED HACKATHON TITLES
  static Future<List<String>> getSavedHackathonTitles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyHackathons) ?? [];
  }

  // ✅ TOGGLE SAVED HACKATHON
  static Future<bool> toggleHackathon(String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList(_keyHackathons) ?? [];
    
    bool isSaved;
    if (saved.contains(title)) {
      saved.remove(title);
      isSaved = false;
    } else {
      saved.add(title);
      isSaved = true;
    }
    
    await prefs.setStringList(_keyHackathons, saved);
    return isSaved;
  }
}
