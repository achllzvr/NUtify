import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentSearch {
  final String name;
  final String id;
  final String department;

  StudentSearch({
    required this.name,
    required this.id,
    required this.department,
  });

  static Future<List<StudentSearch>> searchProfessors() async {
    try {
      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=studentGrabTeacherList'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'teacher': 'teacher'}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data');
        
        // Check for both success formats (in case the API returns either)
        bool isSuccess = (data['success'] == true) || (data['error'] == false);
        
        if (isSuccess && data['teachers'] != null) {
          List<dynamic> teachers = data['teachers'];
          print('Teachers found: ${teachers.length}');
          
          return teachers.map((teacher) {
            return StudentSearch(
              name: teacher['full_name'] ?? '${teacher['user_fn'] ?? ''} ${teacher['user_ln'] ?? ''}'.trim(),
              id: teacher['user_id']?.toString() ?? '',
              department: teacher['department'] ?? 'No Department Assigned',
            );
          }).toList();
        } else {
          print('API Error: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching teachers: $e');
    }
    
    // Return empty list if error or no data
    print('Returning empty list - no teachers found or API error');
    return [];
  }
}
