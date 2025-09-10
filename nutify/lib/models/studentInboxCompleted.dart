import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentInboxCompleted {
  final String id;
  final String teacherName;
  final String department;
  final String scheduleDate;
  final String scheduleTime;
  final String appointmentReason;
  final String appointmentRemarks;
  final int? capacity;
  final int? bookedCount;

  StudentInboxCompleted({
    required this.id,
    required this.teacherName,
    required this.department,
    required this.scheduleDate,
    required this.scheduleTime,
  required this.appointmentReason,
  required this.appointmentRemarks,
    this.capacity,
    this.bookedCount,
  });

  factory StudentInboxCompleted.fromJson(Map<String, dynamic> json) {
    return StudentInboxCompleted(
      id: json['id']?.toString() ?? '',
      teacherName: json['teacher_name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      scheduleDate: json['schedule_date']?.toString() ?? '',
      scheduleTime: json['schedule_time']?.toString() ?? '',
  appointmentReason: json['appointment_reason']?.toString() ?? '',
      appointmentRemarks: json['appointment_remarks']?.toString() ?? '',
      capacity: _parseNullableInt(json['capacity']),
      bookedCount: _parseNullableInt(json['booked_count']),
    );
  }

  static int? _parseNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
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
