import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TeacherSchedule {
  final String scheduleId;
  final String teacherId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String status;

  TeacherSchedule({
    required this.scheduleId,
    required this.teacherId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory TeacherSchedule.fromJson(Map<String, dynamic> json) {
    return TeacherSchedule(
      scheduleId: json['schedule_id'].toString(),
      teacherId: json['teacher_id'].toString(),
      dayOfWeek: json['day_of_week'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      status: json['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule_id': scheduleId,
      'teacher_id': teacherId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
    };
  }

  // Static method to get teacher schedules for a specific day
  static Future<List<TeacherSchedule>> getTeacherSchedulesByDay(String dayOfWeek) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) {
        print('Error: User ID not found in shared preferences');
        return [];
      }

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=getTeacherSchedulesByDay'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'teacher_id': userId,
          'day_of_week': dayOfWeek,
        }),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success' && responseData['schedules'] != null) {
          List schedulesJson = responseData['schedules'];
          return schedulesJson.map((json) => TeacherSchedule.fromJson(json)).toList();
        } else {
          print('API response: ${responseData['message'] ?? 'Unknown error'}');
          return [];
        }
      } else {
        print('Failed to load schedules. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching teacher schedules: $e');
      return [];
    }
  }

  // Static method to get all teacher schedules
  static Future<List<TeacherSchedule>> getAllTeacherSchedules() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) {
        print('Error: User ID not found in shared preferences');
        return [];
      }

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=getAllTeacherSchedules'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'teacher_id': userId,
        }),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success' && responseData['schedules'] != null) {
          List schedulesJson = responseData['schedules'];
          return schedulesJson.map((json) => TeacherSchedule.fromJson(json)).toList();
        } else {
          print('API response: ${responseData['message'] ?? 'Unknown error'}');
          return [];
        }
      } else {
        print('Failed to load schedules. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching teacher schedules: $e');
      return [];
    }
  }

  // Static method to add a new schedule
  static Future<bool> addSchedule({
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) {
        print('Error: User ID not found in shared preferences');
        return false;
      }

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=addTeacherSchedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'teacher_id': userId,
          'day_of_week': dayOfWeek,
          'start_time': startTime,
          'end_time': endTime,
        }),
      );

      print('Add Schedule API Response Status: ${response.statusCode}');
      print('Add Schedule API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        print('Failed to add schedule. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error adding schedule: $e');
      return false;
    }
  }

  // Static method to update a schedule
  static Future<bool> updateSchedule({
    required String scheduleId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) {
        print('Error: User ID not found in shared preferences');
        return false;
      }

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=updateTeacherSchedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'schedule_id': scheduleId,
          'teacher_id': userId,
          'day_of_week': dayOfWeek,
          'start_time': startTime,
          'end_time': endTime,
        }),
      );

      print('Update Schedule API Response Status: ${response.statusCode}');
      print('Update Schedule API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        print('Failed to update schedule. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating schedule: $e');
      return false;
    }
  }

  // Static method to delete a schedule
  static Future<bool> deleteSchedule(String scheduleId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) {
        print('Error: User ID not found in shared preferences');
        return false;
      }

      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=deleteTeacherSchedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'schedule_id': scheduleId,
          'teacher_id': userId,
        }),
      );

      print('Delete Schedule API Response Status: ${response.statusCode}');
      print('Delete Schedule API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        print('Failed to delete schedule. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting schedule: $e');
      return false;
    }
  }

  @override
  String toString() {
    return 'TeacherSchedule{scheduleId: $scheduleId, teacherId: $teacherId, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, status: $status}';
  }
}
