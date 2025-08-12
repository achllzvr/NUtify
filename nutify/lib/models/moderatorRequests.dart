import 'dart:convert';
import 'package:http/http.dart' as http;

class ModeratorRequestItem {
  final int appointmentId;
  final String teacherName;
  final String studentName;
  final String reason;
  final String status;
  final String createdAt;

  ModeratorRequestItem({
    required this.appointmentId,
    required this.teacherName,
    required this.studentName,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory ModeratorRequestItem.fromJson(Map<String, dynamic> j) => ModeratorRequestItem(
        appointmentId: int.tryParse(j['appointment_id']?.toString() ?? '') ?? 0,
        teacherName: j['teacher_name'] ?? '',
        studentName: j['student_name'] ?? '',
        reason: j['appointment_reason'] ?? '',
        status: j['status'] ?? '',
        createdAt: j['created_at'] ?? '',
      );
}

class ModeratorRequestsApi {
  static const String baseUrl = 'https://nutify.site/api.php';

  static Future<List<ModeratorRequestItem>> fetchRequests() async {
    final res = await http.post(
      Uri.parse('$baseUrl?action=getModeratorRequests'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    );
    if (res.statusCode != 200) return [];
    try {
      final data = jsonDecode(res.body);
      final list = (data['requests'] ?? data['data'] ?? []) as List;
      return list.map((e) => ModeratorRequestItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<ModeratorRequestItem>> fetchOnTheSpotRequests() async {
    final res = await http.get(Uri.parse('$baseUrl?action=getModeratorOnTheSpotRequests'));
    if (res.statusCode != 200) return [];
    try {
      final data = jsonDecode(res.body);
      final list = (data['requests'] ?? data['data'] ?? []) as List;
      return list.map((e) => ModeratorRequestItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createOnSpotRequest({
    required int teacherId,
    required int studentId,
    required String reason,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl?action=moderatorCreateOnSpotRequest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'teacher_id': teacherId,
        'student_id': studentId,
        'appointment_reason': reason,
      }),
    );
    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return {'error': true, 'message': 'Unexpected server response'};
    }
  }
}
