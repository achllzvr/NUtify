import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentInboxPending {
  final String id;
  final String teacherName;
  final String department;
  final String scheduleDate;
  final String scheduleTime;
  final String appointmentReason;
  final String appointmentRemarks;
  final int? capacity;

  StudentInboxPending({
    required this.id,
    required this.teacherName,
    required this.department,
    required this.scheduleDate,
    required this.scheduleTime,
  required this.appointmentReason,
  required this.appointmentRemarks,
  this.capacity,
  });

  factory StudentInboxPending.fromJson(Map<String, dynamic> json) {
    return StudentInboxPending(
      id: json['id']?.toString() ?? '',
      teacherName: json['teacher_name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      scheduleDate: json['schedule_date']?.toString() ?? '',
      scheduleTime: json['schedule_time']?.toString() ?? '',
  appointmentReason: json['appointment_reason']?.toString() ?? '',
      appointmentRemarks: json['appointment_remarks']?.toString() ?? '',
  capacity: _parseNullableInt(json['capacity']),
    );
  }

  static int? _parseNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static Future<List<StudentInboxPending>> getStudentInboxPendings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) {
        print('No user ID found in session');
        return [];
      }

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=getStudentInboxPending'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userID': userId}),
      );

      print('Pending Response status: ${response.statusCode}');
      print('Pending Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['appointments'] != null) {
          List<dynamic> appointments = data['appointments'];
          return appointments.map((appointment) => StudentInboxPending.fromJson(appointment)).toList();
        }
      }
    } catch (e) {
      print('Error fetching pending appointments: $e');
    }
    
    return [];
  }
}
