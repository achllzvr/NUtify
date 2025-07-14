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

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=studentFetchHistory'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userID': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['appointments'] != null) {
          List<dynamic> appointments = data['appointments'];
          
          // Get unique teachers from recent appointments
          Map<String, RecentProfessor> uniqueTeachers = {};
          
          for (var appointment in appointments) {
            String teacherId = appointment['teacher_id']?.toString() ?? '';
            if (teacherId.isNotEmpty && !uniqueTeachers.containsKey(teacherId)) {
              uniqueTeachers[teacherId] = RecentProfessor.fromJson(appointment);
            }
          }
          
          // Return up to 5 most recent professors
          return uniqueTeachers.values.take(5).toList();
        }
      }
    } catch (e) {
      print('Error fetching recent professors: $e');
    }
    
    // Return empty list if error or no data
    return [];
  }
}
