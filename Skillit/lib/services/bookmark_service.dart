import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

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
    
    bool isAdding;
    if (saved.contains(title)) {
      saved.remove(title);
      isAdding = false;
    } else {
      saved.add(title);
      isAdding = true;
    }
    
    await prefs.setStringList(_keyInternships, saved);
    
    // Background sync with API
    ApiService.toggleSavedItem('internship', title, isAdding);
    
    return isAdding;
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
    
    bool isAdding;
    if (saved.contains(title)) {
      saved.remove(title);
      isAdding = false;
    } else {
      saved.add(title);
      isAdding = true;
    }
    
    await prefs.setStringList(_keyHackathons, saved);
    
    // Background sync with API
    ApiService.toggleSavedItem('hackathon', title, isAdding);
    
    return isAdding;
  }

  // ✅ SYNC ALL LOCAL TO BACKEND (Optional helper)
  static Future<void> syncAllToBackend() async {
    try {
      final profile = await ApiService.getUserProfile();
      if (profile.containsKey('error')) return;

      final prefs = await SharedPreferences.getInstance();
      
      if (profile['savedInternships'] != null) {
        await prefs.setStringList(_keyInternships, List<String>.from(profile['savedInternships']));
      }
      
      if (profile['savedHackathons'] != null) {
        await prefs.setStringList(_keyHackathons, List<String>.from(profile['savedHackathons']));
      }
    } catch (e) {
      print("Sync error: $e");
    }
  }
}
