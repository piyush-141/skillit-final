import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hackathon_model.dart';
import '../data/mock_hackathons.dart';

class HackathonService {
  // ✅ REAL API OR MOCK DATA
  static const bool USE_MOCK_DATA = false; // Set to true if API fails
  static const String API_BASE_URL = "http://10.0.2.2:5000/api"; // Android Emulator

  // Fetch all hackathons
  static Future<List<Hackathon>> fetchHackathons() async {
    if (USE_MOCK_DATA) {
      // 📌 Mock data (fallback)
      await Future.delayed(Duration(milliseconds: 500));
      return MockHackathons.getAll();
    } else {
      // 🚀 Real API call
      try {
        print("🔵 HACKATHONS - Fetching from: $API_BASE_URL/hackathons");
        
        final response = await http.get(
          Uri.parse('$API_BASE_URL/hackathons'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        print("📊 Status Code: ${response.statusCode}");

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          print("✅ Fetched ${data.length} hackathons");
          
          return data.map((json) => Hackathon.fromJson(json)).toList();
        } else {
          print("❌ Failed - Status: ${response.statusCode}");
          print("📦 Response: ${response.body}");
          
          // Fallback to mock data
          return MockHackathons.getAll();
        }
      } catch (e) {
        print("🔴 ERROR: $e");
        print("⚠️ Falling back to mock data");
        
        // Fallback to mock data on error
        return MockHackathons.getAll();
      }
    }
  }

  // Fetch by mode
  static Future<List<Hackathon>> fetchByMode(String mode) async {
    List<Hackathon> all = await fetchHackathons();
    if (mode == "All") return all;
    return all.where((item) => item.mode == mode).toList();
  }

  // Search hackathons
  static Future<List<Hackathon>> searchHackathons(String query) async {
    List<Hackathon> all = await fetchHackathons();
    return all.where((item) {
      return item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.organizer.toLowerCase().contains(query.toLowerCase()) ||
          item.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }
}