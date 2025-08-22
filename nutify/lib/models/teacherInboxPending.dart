import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherInboxPending {
  final String id;
  final String studentName;
  final String department;
  final String scheduleDate;
  final String scheduleTime;
  final String appointmentReason;
  final String appointmentRemarks;

  TeacherInboxPending({
    required this.id,
    required this.studentName,
    required this.department,
    required this.scheduleDate,
    required this.scheduleTime,
  required this.appointmentReason,
  required this.appointmentRemarks,
  });

  factory TeacherInboxPending.fromJson(Map<String, dynamic> json) {
    return TeacherInboxPending(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      scheduleDate: json['schedule_date']?.toString() ?? '',
      scheduleTime: json['schedule_time']?.toString() ?? '',
  appointmentReason: json['appointment_reason']?.toString() ?? '',
  appointmentRemarks: json['appointment_remarks']?.toString() ?? '',
    );
  }

  static Future<List<TeacherInboxPending>> getTeacherInboxPendings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) {
        print('No user ID found in session');
        return [];
      }

      print('Using teacher ID for pending appointments: $userId');

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=getTeacherInboxPending'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'teacher_id': userId,
        }),
      );

      print('Teacher pending appointments API response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success') {
          final List<dynamic> appointmentsJson = responseData['data'] ?? [];
          return appointmentsJson.map((json) => TeacherInboxPending.fromJson(json)).toList();
        } else {
          print('API Error: ${responseData['message']}');
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching teacher pending appointments: $e');
      return [];
    }
  }
}
