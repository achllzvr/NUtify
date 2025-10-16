import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class OngoingAppointment {
  final int id;
  final String status;
  final String scheduleDate;
  final String startTime;
  final String endTime;
  final String scheduleTime;
  final int teacherId;
  final int studentId;
  final String teacherName;
  final String studentName;
  final String reason;
  final String remarks;

  OngoingAppointment({
    required this.id,
    required this.status,
    required this.scheduleDate,
    required this.startTime,
    required this.endTime,
    required this.scheduleTime,
    required this.teacherId,
    required this.studentId,
    required this.teacherName,
    required this.studentName,
    required this.reason,
    required this.remarks,
  });

  factory OngoingAppointment.fromJson(Map<String, dynamic> j) {
    return OngoingAppointment(
      id: int.tryParse(j['id']?.toString() ?? '') ?? 0,
      status: j['status']?.toString() ?? 'ongoing',
      scheduleDate: j['schedule_date']?.toString() ?? '',
      startTime: j['start_time']?.toString() ?? '',
      endTime: j['end_time']?.toString() ?? '',
      scheduleTime: j['schedule_time']?.toString() ?? '',
      teacherId: int.tryParse(j['teacher_id']?.toString() ?? '') ?? 0,
      studentId: int.tryParse(j['student_id']?.toString() ?? '') ?? 0,
      teacherName: j['teacher_name']?.toString() ?? '',
      studentName: j['student_name']?.toString() ?? '',
      reason: j['appointment_reason']?.toString() ?? '',
      remarks: j['appointment_remarks']?.toString() ?? '',
    );
  }
}

class OngoingService {
  static final OngoingService _inst = OngoingService._();
  factory OngoingService() => _inst;
  OngoingService._();

  final ValueNotifier<OngoingAppointment?> current = ValueNotifier<OngoingAppointment?>(null);
  Timer? _timer;
  int? _userId;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = int.tryParse((prefs.getString('userId') ?? '').toString());
  }

  void start({Duration interval = const Duration(seconds: 7)}) async {
    // Always (re)read user id from prefs when starting
    await init();
    // Run immediately
    unawaited(refresh());
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => refresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refresh() async {
    // If we don't yet have a user id (e.g., just logged in), try to (re)load
    if (_userId == null || _userId == 0) {
      await init();
    }
    final uid = _userId;
    if (uid == null || uid <= 0) return;
    try {
      final resp = await http.post(
        Uri.parse('https://nutify.site/api.php?action=getOngoingAppointmentForUser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': uid}),
      );
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final data = jsonDecode(resp.body);
        if (data is Map && data['success'] == true) {
          if (data['ongoing'] != null) {
            current.value = OngoingAppointment.fromJson(Map<String, dynamic>.from(data['ongoing']));
          } else {
            current.value = null;
          }
        }
      }
    } catch (_) {
      // swallow network errors silently
    }
  }
}
