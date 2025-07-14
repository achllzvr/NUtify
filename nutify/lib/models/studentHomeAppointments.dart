import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHomeAppointments {
  final String name;
  final String id;
  final String timestamp;
  final String status;
  final String scheduleDate;
  final String scheduleTime;
  final bool isSelected;

  StudentHomeAppointments({
    required this.name,
    required this.id,
    required this.timestamp,
    required this.status,
    required this.scheduleDate,
    required this.scheduleTime,
    this.isSelected = false,
  });

  factory StudentHomeAppointments.fromJson(Map<String, dynamic> json) {
    return StudentHomeAppointments(
      name: '${json['teacher_fn'] ?? ''} ${json['teacher_ln'] ?? ''}'.trim(),
      id: json['appointment_id']?.toString() ?? '',
      timestamp: json['created_at'] ?? '',
      status: json['status'] ?? 'pending',
      scheduleDate: json['schedule_date'] ?? '',
      scheduleTime: json['schedule_time'] ?? '',
      isSelected: false,
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

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=studentFetchInbox'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userID': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['appointments'] != null) {
          List<dynamic> appointments = data['appointments'];
          
          // Filter for upcoming appointments (accepted or pending status)
          List<StudentHomeAppointments> upcomingAppointments = appointments
              .where((appointment) => 
                  appointment['status'] == 'accepted' || 
                  appointment['status'] == 'pending')
              .map((appointment) => StudentHomeAppointments.fromJson(appointment))
              .toList();
          
          // Sort by schedule date/time
          upcomingAppointments.sort((a, b) {
            DateTime dateA = DateTime.tryParse('${a.scheduleDate} ${a.scheduleTime}') ?? DateTime.now();
            DateTime dateB = DateTime.tryParse('${b.scheduleDate} ${b.scheduleTime}') ?? DateTime.now();
            return dateA.compareTo(dateB);
          });
          
          return upcomingAppointments;
        }
      }
    } catch (e) {
      print('Error fetching student appointments: $e');
    }
    
    // Return empty list if error or no data
    return [];
  }
}
