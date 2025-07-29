
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ModeratorHomeAppointments {
  final String id;
  final String teacherName;
  final String studentName;
  final String scheduleTime;
  final String scheduleDate;
  final String appointmentReason;

  ModeratorHomeAppointments({
    required this.id,
    required this.teacherName,
    required this.studentName,
    required this.scheduleTime,
    required this.scheduleDate,
    required this.appointmentReason,
  });

  factory ModeratorHomeAppointments.fromJson(Map<String, dynamic> json) {
    return ModeratorHomeAppointments(
      id: json['id']?.toString() ?? '',
      teacherName: json['teacher_name']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      scheduleTime: json['schedule_time']?.toString() ?? '',
      scheduleDate: json['schedule_date']?.toString() ?? '',
      appointmentReason: json['appointment_reason']?.toString() ?? '',
    );
  }

  static Future<List<ModeratorHomeAppointments>> getModeratorHomeAppointments() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId == null) {
        print('No user ID found in session');
        return [];
      }
      print('Using user ID for moderator home appointments: $userId');
      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=getModeratorHomeAppointments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userID': userId}),
      );
      print('Moderator Home Appointments Response status: ${response.statusCode}');
      print('Moderator Home Appointments Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['appointments'] != null) {
          List<dynamic> appointments = data['appointments'];
          return appointments.map((appointment) => ModeratorHomeAppointments.fromJson(appointment)).toList();
        }
      }
    } catch (e) {
      print('Error fetching moderator appointments: $e');
    }
    // Return empty list if error or no data
    return [];
  }
}

