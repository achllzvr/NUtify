import 'package:flutter/material.dart';
import 'package:nutify/pages/teacherInbox.dart';
import 'package:nutify/pages/teacherProfile.dart';
import 'package:nutify/models/teacherHomeAppointments.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:nutify/services/user_status_service.dart';

class TeacherHome extends StatefulWidget {
  TeacherHome({super.key});

  @override
  _TeacherHomeState createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  String? teacherUserId;
  String _userStatus = 'online';
  bool _statusLoading = false;
  // Search state
  final TextEditingController _homeSearchController = TextEditingController();
  String _homeQuery = '';
  // Cache the future to avoid refetching on each rebuild
  Future<List<TeacherHomeAppointments>>? _homeFuture;
  
  // Refresh helper: re-fetch home data
  void _refreshHome() {
    setState(() {
      _homeFuture = TeacherHomeAppointments.getTeacherHomeAppointments();
    });
  }
  
  // Async version for pull-to-refresh
  Future<void> _refreshHomeAsync() async {
    final fut = TeacherHomeAppointments.getTeacherHomeAppointments();
    setState(() {
      _homeFuture = fut;
    });
    await fut;
  }
  
  @override
  void initState() {
    super.initState();
    _loadTeacherUserId();
    _homeFuture = TeacherHomeAppointments.getTeacherHomeAppointments();
    _homeSearchController.addListener(() {
      if (_homeQuery != _homeSearchController.text) {
        setState(() {
          _homeQuery = _homeSearchController.text;
        });
      }
    });
    _initUserStatus();
  }

  Future<void> _initUserStatus() async {
    setState(() => _statusLoading = true);
    final s = await UserStatusService.fetchStatus();
    setState(() {
      if (s != null) _userStatus = s;
      _statusLoading = false;
    });
  }

  Future<void> _cycleStatus() async {
    if (_statusLoading) return;
    final order = ['online', 'busy', 'offline'];
    final idx = order.indexOf(_userStatus);
    final next = order[(idx + 1) % order.length];
    setState(() => _statusLoading = true);
    final ok = await UserStatusService.updateStatus(next);
    setState(() {
      if (ok) _userStatus = next;
      _statusLoading = false;
    });
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status', style: TextStyle(fontFamily: 'Arimo', color: Colors.white)), backgroundColor: Colors.red),
      );
    }
  }
  
  Future<void> _loadTeacherUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      teacherUserId = prefs.getString('userId');
    });
  }

  @override
  void dispose() {
    _homeSearchController.dispose();
    super.dispose();
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
  future: _homeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<TeacherHomeAppointments> all = snapshot.data ?? [];

        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);

        // Upcoming: all appointments from today onward (today and future)
        final upcoming = all.where((a) {
          final start = _parseStartDateTime(a);
          if (start != null) {
            return !start.isBefore(startOfToday); // >= startOfToday
          }
          final d = _parseDateOnly(a.scheduleDate);
          return d != null && !d.isBefore(startOfToday);
        }).toList()
          ..sort((a, b) {
            final da = _parseStartDateTime(a) ?? _parseDateOnly(a.scheduleDate) ?? DateTime(2100);
            final db = _parseStartDateTime(b) ?? _parseDateOnly(b.scheduleDate) ?? DateTime(2100);
            return da.compareTo(db);
          });

        // Missed: strictly before today (yesterday and earlier)
        final missed = all.where((a) {
          final start = _parseStartDateTime(a);
          if (start != null) {
            return start.isBefore(startOfToday);
          }
          final d = _parseDateOnly(a.scheduleDate);
          return d != null && d.isBefore(startOfToday);
        }).toList()
          ..sort((a, b) {
            final da = _parseStartDateTime(a) ?? _parseDateOnly(a.scheduleDate) ?? DateTime(1900);
            final db = _parseStartDateTime(b) ?? _parseDateOnly(b.scheduleDate) ?? DateTime(1900);
            return db.compareTo(da); // newest missed first
          });

        // Apply query filtering
        bool hasQuery = _homeQuery.trim().isNotEmpty;
        if (hasQuery) {
          final q = _homeQuery.toLowerCase().trim();
          bool matches(TeacherHomeAppointments a) {
            return (
              (a.studentName).toLowerCase().contains(q) ||
              (a.department).toLowerCase().contains(q) ||
              (a.appointmentReason).toLowerCase().contains(q) ||
              (a.appointmentRemarks).toLowerCase().contains(q) ||
              (a.scheduleDate).toLowerCase().contains(q) ||
              (a.scheduleTime).toLowerCase().contains(q)
            );
          }
          upcoming.retainWhere(matches);
          missed.retainWhere(matches);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _homeSearchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search by student, department, reason...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
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
              child: upcoming.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _refreshHomeAsync,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'No upcoming appointments',
                              style: TextStyle(fontFamily: 'Arimo', fontSize: 14, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshHomeAsync,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: upcoming.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildAppointmentCard(upcoming[index]),
                      ),
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
                  ? RefreshIndicator(
                      onRefresh: _refreshHomeAsync,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'No missed appointments',
                              style: TextStyle(fontFamily: 'Arimo', fontSize: 14, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshHomeAsync,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: missed.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildAppointmentCard(missed[index]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  DateTime? _parseStartDateTime(TeacherHomeAppointments a) {
    try {
      // Parse date: try ISO first, then human-readable like 'August 19' (assume current year)
      DateTime date;
      try {
        // Handles 'YYYY-MM-DD' or 'YYYY-MM-DD HH:mm:ss'
        date = DateTime.parse(a.scheduleDate);
      } catch (_) {
        // Try 'MMMM d, y'
        try {
          date = DateFormat('MMMM d, y').parseStrict(a.scheduleDate);
        } catch (_) {
          // Try 'MMMM d' with current year
          final now = DateTime.now();
          final md = DateFormat('MMMM d').parseStrict(a.scheduleDate);
          date = DateTime(now.year, md.month, md.day);
        }
      }

      // Extract start time portion (before dash if a range like "08:00 AM - 09:00 AM")
      String startStr = a.scheduleTime.contains('-')
          ? a.scheduleTime.split('-')[0].trim()
          : a.scheduleTime.trim();

      // Parse time: support 24h and 12h with AM/PM
      DateTime t;
      bool parsed = false;
      for (final fmt in ['HH:mm:ss', 'HH:mm', 'h:mm a', 'hh:mm a']) {
        try {
          t = DateFormat(fmt).parseStrict(startStr);
          parsed = true;
          // Combine and return
          return DateTime(date.year, date.month, date.day, t.hour, t.minute, t.second);
        } catch (_) {
          // try next format
        }
      }
      if (!parsed) return null;
      return null;
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseDateOnly(String scheduleDate) {
    try {
      // Try ISO date first
      try {
        return DateTime.parse(scheduleDate.split(' ').first);
      } catch (_) {
        // Try 'MMMM d, y'
        try {
          return DateFormat('MMMM d, y').parseStrict(scheduleDate);
        } catch (_) {
          // Try 'MMMM d' with current year
          final now = DateTime.now();
          final md = DateFormat('MMMM d').parseStrict(scheduleDate);
          return DateTime(now.year, md.month, md.day);
        }
      }
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
                        if (appointment.appointmentReason.isNotEmpty) ...[
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
                        if (appointment.appointmentRemarks.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            'Remarks: ${appointment.appointmentRemarks}',
                            style: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 12,
                              color: Colors.grey.shade700,
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
        _refreshHome(); // Reload data
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
        _refreshHome(); // Reload data
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
        // Status toggle
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _cycleStatus,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _statusLoading
                      ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : Icon(
                          _userStatus == 'online'
                              ? Icons.circle
                              : _userStatus == 'busy'
                                  ? Icons.do_not_disturb_on
                                  : Icons.circle_outlined,
                          size: 16,
                          color: _userStatus == 'online'
                              ? Colors.limeAccent
                              : _userStatus == 'busy'
                                  ? Colors.orangeAccent
                                  : Colors.white70,
                        ),
                  const SizedBox(width: 6),
                  Text(
                    _userStatus[0].toUpperCase() + _userStatus.substring(1),
                    style: const TextStyle(fontFamily: 'Arimo', color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
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