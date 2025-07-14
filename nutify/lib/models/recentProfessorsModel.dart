import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentProfessor {
  final String name;
  final String id;
  final String department;

  RecentProfessor({
    required this.name,
    required this.id,
    required this.department,
  });

  factory RecentProfessor.fromJson(Map<String, dynamic> json) {
    String firstName = json['teacher_fn'] ?? '';
    String lastName = json['teacher_ln'] ?? '';
    
    return RecentProfessor(
      name: '$firstName $lastName'.trim(),
      id: json['teacher_id']?.toString() ?? '',
      department: json['department'] ?? 'No Department Assigned',
    );
  }

  static Future<List<RecentProfessor>> getRecentProfessors() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) {
        print('No user ID found in session');
        return [];
      }

      print('Using user ID for recent professors: $userId');

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=getRecentProfessors'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userID': userId}),
      );

      print('Recent Professors Response status: ${response.statusCode}');
      print('Recent Professors Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['professors'] != null) {
          List<dynamic> professors = data['professors'];
          return professors.map((professor) => RecentProfessor.fromJson(professor)).toList();
        }
      }
    } catch (e) {
      print('Error fetching recent professors: $e');
    }
    
    // Return empty list if error or no data
    return [];
  }
}
