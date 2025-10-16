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
  final String appointmentRemarks;

  StudentHomeAppointments({
    required this.id,
    required this.teacherName,
    required this.department,
    required this.scheduleDate,
    required this.scheduleTime,
  required this.appointmentReason,
  required this.appointmentRemarks,
  });

  factory StudentHomeAppointments.fromJson(Map<String, dynamic> json) {
    return StudentHomeAppointments(
      id: json['id']?.toString() ?? '',
      teacherName: json['teacher_name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      scheduleDate: json['schedule_date']?.toString() ?? '',
      scheduleTime: json['schedule_time']?.toString() ?? '',
  appointmentReason: json['appointment_reason']?.toString() ?? '',
  appointmentRemarks: json['appointment_remarks']?.toString() ?? '',
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

      // Some backends accept different param keys; send a superset
      final body = {
        'userID': userId,
        'user_id': userId,
        'student_id': userId,
        // Request accepted appointments explicitly across all dates (backend may ignore unknown keys)
        'status': 'accepted',
        'accepted_only': true,
        'include_all_accepted': true,
      };
      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=getStudentHomeAppointments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      print('Student Home Appointments Response status: ${response.statusCode}');
      print('Student Home Appointments Response body: ${response.body}');

      if (response.statusCode == 200) {
        final raw = response.body.trim();
        if (raw.isEmpty) return [];
        final data = json.decode(raw);

        List<dynamic>? list;
        if (data is List) {
          list = data;
        } else if (data is Map) {
          // Prefer appointments key
          if (data['appointments'] is List) list = data['appointments'];
          // Fallback keys used in some routes
          else if (data['data'] is List) list = data['data'];
          else if (data['rows'] is List) list = data['rows'];
        }

        if (list != null) {
          // Map and dedup by id
          final mapped = list
              .map((e) => StudentHomeAppointments.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          final seen = <String>{};
          final deduped = mapped.where((a) => seen.add(a.id)).toList();
          return deduped;
        }
      }
    } catch (e) {
      print('Error fetching student appointments: $e');
    }
    
    // Return empty list if error or no data
    return [];
  }
}
