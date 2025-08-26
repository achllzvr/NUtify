import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherHomeAppointments {
  final String id;
  final String studentName;
  final String department;
  final String scheduleDate;
  final String scheduleTime;
  final String status;
  final String appointmentReason;
  final String appointmentRemarks;

  TeacherHomeAppointments({
    required this.id,
    required this.studentName,
    required this.department,
    required this.scheduleDate,
    required this.scheduleTime,
    required this.status,
  required this.appointmentReason,
  required this.appointmentRemarks,
  });

  factory TeacherHomeAppointments.fromJson(Map<String, dynamic> json) {
    // Prefer schedule_date/time but gracefully fall back to appointment_date and start/end times
    final String rawScheduleDate = (json['schedule_date'] ?? json['appointment_date'] ?? '').toString();
    // schedule_time may be a range already; if missing, compose from start_time/end_time or from appointment_date time
    String rawScheduleTime = (json['schedule_time'] ?? '').toString();
    if (rawScheduleTime.isEmpty) {
      final String start = (json['start_time'] ?? json['startTime'] ?? '').toString();
      final String end = (json['end_time'] ?? json['endTime'] ?? '').toString();
      if (start.isNotEmpty && end.isNotEmpty) {
        rawScheduleTime = '$start - $end';
      } else if (start.isNotEmpty) {
        rawScheduleTime = start;
      } else if (rawScheduleDate.contains(' ')) {
        // Extract time part from appointment_date if present
        final parts = rawScheduleDate.split(' ');
        if (parts.length > 1) rawScheduleTime = parts[1];
      }
    }
    return TeacherHomeAppointments(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      scheduleDate: rawScheduleDate,
      scheduleTime: rawScheduleTime,
      status: json['status']?.toString() ?? '',
  appointmentReason: json['appointment_reason']?.toString() ?? '',
  appointmentRemarks: json['appointment_remarks']?.toString() ?? '',
    );
  }

  static Future<List<TeacherHomeAppointments>> getTeacherHomeAppointments() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) {
        print('No user ID found in session');
        return [];
      }

      print('Using teacher ID for home appointments: $userId');

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=getTeacherHomeAppointments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'teacher_id': userId,
        }),
      );

      print('Teacher home appointments API response: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded.map<TeacherHomeAppointments>((e) => TeacherHomeAppointments.fromJson(e as Map<String, dynamic>)).toList();
        } else if (decoded is Map<String, dynamic>) {
          final bool ok = (decoded['status'] == 'success') || (decoded['success'] == true);
          if (ok) {
            final List<dynamic> appointmentsJson = (decoded['data'] ?? decoded['appointments'] ?? []) as List<dynamic>;
            return appointmentsJson.map((j) => TeacherHomeAppointments.fromJson(j as Map<String, dynamic>)).toList();
          } else {
            print('API Error: ${decoded['message'] ?? 'Unknown error'}');
            return [];
          }
        } else {
          print('Unexpected response shape');
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching teacher home appointments: $e');
      return [];
    }
  }
}
