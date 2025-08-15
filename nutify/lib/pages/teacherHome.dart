import 'package:flutter/material.dart';
import 'package:nutify/pages/teacherInbox.dart';
import 'package:nutify/pages/teacherProfile.dart';
import 'package:nutify/models/teacherHomeAppointments.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TeacherHome extends StatefulWidget {
  TeacherHome({super.key});

  @override
  _TeacherHomeState createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  String? teacherUserId;
  
  @override
  void initState() {
    super.initState();
    _loadTeacherUserId();
  }
  
  Future<void> _loadTeacherUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      teacherUserId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildTeacherAppBar(context),
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    // Fetch once and split into two scrollable sections
    return FutureBuilder<List<TeacherHomeAppointments>>(
      future: TeacherHomeAppointments.getTeacherHomeAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<TeacherHomeAppointments> all = snapshot.data ?? [];

        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);

        // Upcoming: only today and not in the past (relative to now)
        final upcomingToday = all.where((a) {
          final start = _parseStartDateTime(a);
          if (start != null) {
            final isToday = start.year == startOfToday.year && start.month == startOfToday.month && start.day == startOfToday.day;
            return isToday && !start.isBefore(now);
          }
          final d = _parseDateOnly(a.scheduleDate);
          return d != null && d.year == startOfToday.year && d.month == startOfToday.month && d.day == startOfToday.day;
        }).toList();

        // Missed: strictly before today (yesterday and earlier)
        final missed = all.where((a) {
          final start = _parseStartDateTime(a);
          if (start != null) {
            return start.isBefore(startOfToday);
          }
          final d = _parseDateOnly(a.scheduleDate);
          return d != null && d.isBefore(startOfToday);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Your Upcoming Appointments...',
                style: TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: upcomingToday.isEmpty
                  ? const Center(
                      child: Text(
                        'No upcoming appointments',
                        style: TextStyle(fontFamily: 'Arimo', fontSize: 14, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: upcomingToday.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _buildAppointmentCard(upcomingToday[index]),
                    ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Your Missed Appointments...',
                style: TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: missed.isEmpty
                  ? const Center(
                      child: Text(
                        'No missed appointments',
                        style: TextStyle(fontFamily: 'Arimo', fontSize: 14, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: missed.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _buildAppointmentCard(missed[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  DateTime? _parseStartDateTime(TeacherHomeAppointments a) {
    try {
      // Parse date (handles 'YYYY-MM-DD' or 'YYYY-MM-DD HH:mm:ss')
      DateTime date;
      try {
        date = DateTime.parse(a.scheduleDate);
      } catch (_) {
        final dOnly = a.scheduleDate.split(' ').first;
        date = DateTime.parse(dOnly);
      }

      // Extract start time
      String startStr = a.scheduleTime.contains('-')
          ? a.scheduleTime.split('-')[0].trim()
          : a.scheduleTime.trim();

      DateTime t;
      try {
        t = DateFormat('HH:mm:ss').parse(startStr);
      } catch (_) {
        t = DateFormat('HH:mm').parse(startStr);
      }

      return DateTime(date.year, date.month, date.day, t.hour, t.minute, t.second);
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseDateOnly(String scheduleDate) {
    try {
      return DateTime.parse(scheduleDate.split(' ').first);
    } catch (_) {
      return null;
    }
  }

  Widget _buildAppointmentCard(TeacherHomeAppointments appointment) {
    // Get initials for avatar
    String initials = appointment.studentName.split(' ').map((name) => name.isNotEmpty ? name[0] : '').take(2).join('').toUpperCase();

    return GestureDetector(
      onTap: () {
        if (teacherUserId != null) {
          print('Accepted appointment ID: ${appointment.id}');
          _callStudentToAppointment(appointment.id, teacherUserId!);
        } else {
          // Handle the case where userID is not loaded yet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User ID not loaded')),
          );
        }
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF81C784), // Green for accepted
                          Color(0xFF66BB6A), // Darker green
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.studentName,
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          appointment.department,
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${appointment.scheduleDate} • ${appointment.scheduleTime}',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (appointment.appointmentReason != null && appointment.appointmentReason!.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            'Reason: ${appointment.appointmentReason}',
                            style: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)], // Darker Green
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _showStatusConfirmationDialog(
                            context,
                            'completed',
                            appointment.id,
                            () async {
                              final result = await _updateAppointmentStatus(appointment.id, 'completed', teacherUserId!);
                              if (result['error'] == false) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Appointment marked as completed!', style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
                                    backgroundColor: Color(0xFF35408E),
                                  ),
                                );
                                setState(() {}); // Refresh UI
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ?? 'Failed to update appointment', style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF44336), Color(0xFFB71C1C)], // Darker Red
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFF44336).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _showStatusConfirmationDialog(
                            context,
                            'missed',
                            appointment.id,
                            () async{
                              final result = await _updateAppointmentStatus(appointment.id, 'missed', teacherUserId!);
                              if (result['error'] == false) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Appointment marked as missed!', style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
                                    backgroundColor: Color(0xFF35408E),
                                  ),
                                );
                                setState(() {}); // Refresh UI
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ?? 'Failed to update appointment', style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Missed',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Confirmation dialog method
  Future<void> _showStatusConfirmationDialog(BuildContext context, String status, String appointmentId, Future<void> Function() onConfirm,) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 3,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status Icon with gradient background
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getStatusColor(status).withOpacity(0.1),
                        _getStatusColor(status).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                    size: 30,
                  ),
                ),
                SizedBox(height: 20),
                // Title
                Text(
                  'Confirm Action',
                  style: TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 10),
                // Content
                Text(
                  'Are you sure you want to mark this appointment as $status?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 25),
                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade200,
                              Colors.grey.shade300,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.grey.shade700,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            textStyle: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text('Cancel'),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Continue Button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_getStatusColor(status), _getDarkerStatusColor(status)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor(status).withOpacity(0.4),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop(); // Close dialog
                            print('$status confirmation dialog for appointment id: $appointmentId');
                            await onConfirm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            textStyle: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text('Continue'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to get status color for dialogs
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Color(0xFF4CAF50); // Green
      case 'missed':
        return Color(0xFFF44336); // Red
      default:
        return Color(0xFF4CAF50); // Default green
    }
  }

  // Helper method to get status icons for dialogs
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.task_alt_outlined;
      case 'missed':
        return Icons.error_outline;
      default:
        return Icons.check_circle_outline;
    }
  }

  // Helper method to get darker status colors for gradients
  Color _getDarkerStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Color(0xFF2E7D32); // Darker Green
      case 'missed':
        return Color(0xFFB71C1C); // Darker Red
      default:
        return Color(0xFF2E7D32); // Default darker green
    }
  }

  AppBar _buildTeacherAppBar(BuildContext context) {
    return AppBar(
      title: Container(
        margin: const EdgeInsets.only(left: 10.0),
        child: const Text(
          'Home',
          style: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: false,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF35408E), const Color(0xFF1A2049)],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
      actions: [
        // Profile button
        GestureDetector(
          onTap: () {
            if (ModalRoute.of(context)?.settings.name == '/teacherProfile') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'You are already on the Profile page',
                    style: TextStyle(fontFamily: 'Arimo'),
                  ),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF35408E),
                ),
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherProfile(),
                  settings: RouteSettings(name: '/teacherProfile'),
                ),
                (Route<dynamic> route) => false,
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(right: 25.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/icons/profile.png'),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ],
      // Nav bar below text and profile icon
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Color(0xFFFFD418)),
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name == '/teacherHome' ||
                      context.widget.runtimeType == TeacherHome) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'You are already on the Home page',
                          style: TextStyle(fontFamily: 'Arimo'),
                        ),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color(0xFF35408E),
                      ),
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherHome(),
                        settings: RouteSettings(name: '/teacherHome'),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.inbox, color: Colors.white),
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name == '/teacherInbox') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'You are already on the Inbox page',
                          style: TextStyle(fontFamily: 'Arimo'),
                        ),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color(0xFF35408E),
                      ),
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherInbox(),
                        settings: RouteSettings(name: '/teacherInbox'),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callStudentToAppointment(String appointmentId, String facultyId) async {
    try {
      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=sendTeacherCallNotification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appointment_id': appointmentId,
          'faculty_id': facultyId,
        }),
      );
  
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final result = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] == false
                  ? 'Student called to appointment!'
                  : (result['message'] ?? 'Failed to send notification'),
              style: TextStyle(fontFamily: 'Arimo', color: Colors.white),
            ),
            backgroundColor: result['error'] == false ? Color(0xFF35408E) : Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Server error: ${response.statusCode}\n${response.body}',
              style: TextStyle(fontFamily: 'Arimo', color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: TextStyle(fontFamily: 'Arimo', color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}

Future<Map<String, dynamic>> _updateAppointmentStatus(
    String appointmentId, String status, String facultyId) async {
  // Map status to API action
  String action;
  switch (status) {
    case 'completed':
      action = 'updateAppStatusC';
      break;
    case 'missed':
      action = 'updateAppStatusM';
      break;
    default:
      throw Exception('Invalid status');
  }

  final response = await http.post(
    Uri.parse('https://nutify.site/api.php?action=$action'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'appointment_id': appointmentId,
      'faculty_id': facultyId,
      'status': status,
    }),
  );
  return jsonDecode(response.body);
}