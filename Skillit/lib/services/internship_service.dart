import '../models/internship_model.dart';
import '../data/mock_internships.dart';
// import 'package:http/http.dart' as http; // Uncomment when backend is ready

class InternshipService {
  // 🔥 SWITCH THIS FLAG WHEN BACKEND IS READY
  static const bool USE_MOCK_DATA = true;
  static const String API_BASE_URL = "https://your-backend-url.com/api";

  // Fetch all internships
  static Future<List<Internship>> fetchInternships() async {
    if (USE_MOCK_DATA) {
      // 📌 Mock data (current)
      await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
      return MockInternships.getAll();
    } else {
      // 🚀 Real API call (future)
      /* 
      final response = await http.get(Uri.parse('$API_BASE_URL/internships'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Internship.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load internships');
      }
      */
      return [];
    }
  }

  // Fetch by filter
  static Future<List<Internship>> fetchByType(String type) async {
    List<Internship> all = await fetchInternships();
    if (type == "All") return all;
    return all.where((item) => item.type == type).toList();
  }

  // Search internships
  static Future<List<Internship>> searchInternships(String query) async {
    List<Internship> all = await fetchInternships();
    return all.where((item) {
      return item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.company.toLowerCase().contains(query.toLowerCase()) ||
          item.skills.any((skill) => skill.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }
}