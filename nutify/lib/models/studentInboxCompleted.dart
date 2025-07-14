import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentInboxCompleted {
  final String name;
  final String id;
  final String timestamp;
  final String department;
  final String appointmentId;
  final String day;
  final String startTime;
  final String endTime;
  final bool isSelected;

  StudentInboxCompleted({
    required this.name,
    required this.id,
    required this.timestamp,
    required this.department,
    required this.appointmentId,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.isSelected = false,
  });

  factory StudentInboxCompleted.fromJson(Map<String, dynamic> json) {
    return StudentInboxCompleted(
      name: json['teacher_full_name'] ?? '${json['teacher_fn'] ?? ''} ${json['teacher_ln'] ?? ''}'.trim(),
      id: json['teacher_id']?.toString() ?? '',
      timestamp: json['created_at'] ?? '',
      department: json['department'] ?? 'No Department Assigned',
      appointmentId: json['appointment_id']?.toString() ?? '',
      day: json['day_of_week'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  static Future<List<StudentInboxCompleted>> getStudentInboxCompleted() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) {
        print('No user ID found in session');
        return [];
      }

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=getStudentInboxCompleted'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userID': userId}),
      );

      print('Completed Response status: ${response.statusCode}');
      print('Completed Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['appointments'] != null) {
          List<dynamic> appointments = data['appointments'];
          return appointments.map((appointment) => StudentInboxCompleted.fromJson(appointment)).toList();
        }
      }
    } catch (e) {
      print('Error fetching completed appointments: $e');
    }
    
    return [];
  }
}
