import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHomeAppointments {
  final String id;
  final String teacherName;
  final String department;
  final String scheduleDate;
  final String scheduleTime;
  final String appointmentReason;

  StudentHomeAppointments({
    required this.id,
    required this.teacherName,
    required this.department,
    required this.scheduleDate,
    required this.scheduleTime,
    required this.appointmentReason,
  });

  factory StudentHomeAppointments.fromJson(Map<String, dynamic> json) {
    return StudentHomeAppointments(
      id: json['id']?.toString() ?? '',
      teacherName: json['teacher_name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      scheduleDate: json['schedule_date']?.toString() ?? '',
      scheduleTime: json['schedule_time']?.toString() ?? '',
      appointmentReason: json['appointment_reason']?.toString() ?? '',
    );
  }

  static Future<List<StudentHomeAppointments>> getStudentHomeAppointments() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) {
        print('No user ID found in session');
        return [];
      }

      print('Using user ID for home appointments: $userId');

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=getStudentHomeAppointments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userID': userId}),
      );

      print('Student Home Appointments Response status: ${response.statusCode}');
      print('Student Home Appointments Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['appointments'] != null) {
          List<dynamic> appointments = data['appointments'];
          return appointments.map((appointment) => StudentHomeAppointments.fromJson(appointment)).toList();
        }
      }
    } catch (e) {
      print('Error fetching student appointments: $e');
    }
    
    // Return empty list if error or no data
    return [];
  }
}
