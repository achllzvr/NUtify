import 'package:flutter/material.dart';
import 'package:nutify/pages/moderatorProfile.dart';
import 'package:nutify/pages/moderatorInbox.dart';
import 'package:nutify/models/moderatorHomeAppointments.dart';
import 'package:nutify/models/moderatorRequests.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ModeratorHome extends StatefulWidget {
  ModeratorHome({super.key});

  @override
  _ModeratorHomeState createState() => _ModeratorHomeState();
}

class _ModeratorHomeState extends State<ModeratorHome> {
  String? moderatorUserId;
  bool _isNotifying = false;
  // Added: search and pagination for home
  final TextEditingController _homeSearchCtrl = TextEditingController();
  int _homePage = 0;

  @override
  void initState() {
    super.initState();
    _loadModeratorUserId();
  }

  Future<void> _loadModeratorUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      moderatorUserId = prefs.getString('userId');
    });
  }

  @override
  void dispose() {
    // ...existing code...
    _homeSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildModeratorAppBar(context),
      body: _buildMainContent(),
      floatingActionButton: _buildRequestFab(),
    );
  }

  AppBar _buildModeratorAppBar(BuildContext context) {
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
        GestureDetector(
          onTap: () {
            if (ModalRoute.of(context)?.settings.name == '/moderatorProfile') {
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
                  builder: (context) => ModeratorProfile(),
                  settings: RouteSettings(name: '/moderatorProfile'),
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Color(0xFFFFD418)),
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name == '/moderatorHome' ||
                      context.widget.runtimeType == ModeratorHome) {
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
                        builder: (context) => ModeratorHome(),
                        settings: RouteSettings(name: '/moderatorHome'),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.inbox, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModeratorInbox(),
                      settings: const RouteSettings(name: '/moderatorInbox'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Search bar for home page
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _homeSearchCtrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search by student, faculty, or reason…',
              hintStyle: const TextStyle(fontFamily: 'Arimo'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (_) => setState(() { _homePage = 0; }),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ModeratorHomeAppointments>>(
            future: ModeratorHomeAppointments.getModeratorHomeAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              List<ModeratorHomeAppointments> appointments = snapshot.data ?? [];

              // Only upcoming appointments (filter out past)
              DateTime now = DateTime.now();
              bool isUpcoming(ModeratorHomeAppointments a) {
                try {
                  final date = DateTime.parse(a.scheduleDate);
                  String startStr = a.scheduleTime.contains('-')
                      ? a.scheduleTime.split('-')[0].trim()
                      : a.scheduleTime.trim();
                  DateTime t;
                  try {
                    t = DateFormat('HH:mm:ss').parse(startStr);
                  } catch (_) {
                    t = DateFormat('HH:mm').parse(startStr);
                  }
                  final start = DateTime(date.year, date.month, date.day, t.hour, t.minute, t.second);
                  return start.isAfter(now);
                } catch (_) {
                  // If parsing fails, keep it (be lenient)
                  return true;
                }
              }
              appointments = appointments.where(isUpcoming).toList();

              // Search filter
              final q = _homeSearchCtrl.text.trim().toLowerCase();
              if (q.isNotEmpty) {
                appointments = appointments.where((a) =>
                  a.studentName.toLowerCase().contains(q) ||
                  a.teacherName.toLowerCase().contains(q) ||
                  a.appointmentReason.toLowerCase().contains(q)
                ).toList();
              }

              if (appointments.isEmpty) {
                return Center(
                  child: Text(
                    'No upcoming appointments',
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              // Pagination (10 per page)
              final total = appointments.length;
              final totalPages = (total + 9) ~/ 10;
              int page = _homePage;
              if (page >= totalPages) page = totalPages - 1;
              if (page < 0) page = 0;
              final start = page * 10;
              final end = (start + 10 > total) ? total : start + 10;
              final pageItems = appointments.sublist(start, end);

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.all(16),
                      itemCount: pageItems.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        var appointment = pageItems[index];
                        return _buildAppointmentCard(appointment);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Page ${page + 1} of $totalPages', style: const TextStyle(fontFamily: 'Arimo')),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: page > 0 ? () => setState(() => _homePage = page - 1) : null,
                              child: const Text('Previous'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: page < totalPages - 1 ? () => setState(() => _homePage = page + 1) : null,
                              child: const Text('Next'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(ModeratorHomeAppointments appointment) {
    // Get initials for avatar
    String initials = appointment.teacherName.split(' ').map((name) => name.isNotEmpty ? name[0] : '').take(2).join('').toUpperCase();
    // Generate color based on professor name
    List<Color> avatarColors = [
      Color(0xFF81C784), // Light green
      Color(0xFFFFB74D), // Light orange
      Color(0xFF9575CD), // Light purple
      Color(0xFF4FC3F7), // Light blue
      Color(0xFFFFD54F), // Light yellow
      Color(0xFFFF8A65), // Light coral
    ];
    Color avatarColor = avatarColors[appointment.teacherName.hashCode % avatarColors.length];

    // Format date
    String formattedDate = '';
    try {
      final date = DateTime.parse(appointment.scheduleDate);
      formattedDate = DateFormat('MMMM d, y').format(date);
    } catch (e) {
      formattedDate = appointment.scheduleDate;
    }

    // Format time (expects 'HH:mm:ss - HH:mm:ss' or 'HH:mm:ss')
    String formattedTime = '';
    try {
      if (appointment.scheduleTime.contains('-')) {
        var times = appointment.scheduleTime.split('-');
        var start = times[0].trim();
        var end = times[1].trim();
        final startTime = DateFormat('HH:mm:ss').parse(start);
        final endTime = DateFormat('HH:mm:ss').parse(end);
        formattedTime = '${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}';
      } else {
        final t = DateFormat('HH:mm:ss').parse(appointment.scheduleTime.trim());
        formattedTime = DateFormat('h:mm a').format(t);
      }
    } catch (e) {
      formattedTime = appointment.scheduleTime;
    }

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.0, 1.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.teacherName,
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Student: ${appointment.studentName}',
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 15,
                        color: Colors.blueGrey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '$formattedDate • $formattedTime',
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (appointment.appointmentReason.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        'Reason: ${appointment.appointmentReason}',
                        style: TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              // View Details
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showAppointmentDetails(appointment),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF35408E)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF35408E),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Notify Appointees
              Expanded(
                child: Container
                (
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD418), Color(0xFFFFC107)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFFD418).withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isNotifying
                        ? null
                        : () async {
                            int appId = int.tryParse(appointment.id.toString()) ?? 0;
                            if (appId == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Invalid appointment ID')),
                              );
                              return;
                            }
                            final confirm = await _confirmNotifyDialog();
                            if (confirm != true) return;
                            setState(() => _isNotifying = true);
                            try {
                              final ok = await notifyAppointees(appId);
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Notification sent!', style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
                                    backgroundColor: Color(0xFF43A047),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString(), style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
                                  backgroundColor: Color(0xFFD32F2F),
                                ),
                              );
                            } finally {
                              if (mounted) setState(() => _isNotifying = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _isNotifying
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : Text(
                            'Notify Appointees',
                            style: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestFab() {
    return FloatingActionButton(
      onPressed: _openOnSpotRequestFlow,
      backgroundColor: const Color(0xFFFFD418),
      child: const Icon(Icons.add_comment, color: Colors.black),
    );
  }

  void _openOnSpotRequestFlow() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _OnSpotRequestSheet(onSubmitted: (teacherId, studentId, reason) async {
          final result = await ModeratorRequestsApi.createOnSpotRequest(
            teacherId: teacherId,
            studentId: studentId,
            reason: reason,
          );
          if (mounted) {
            if (result['error'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result['message'] ?? 'Failed'), backgroundColor: const Color(0xFFD32F2F)),
              );
            } else {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request created'), backgroundColor: Color(0xFF43A047)),
              );
              setState(() {});
            }
          }
        });
      },
    );
  }

  Future<bool> notifyAppointees(int appointmentId) async {
    final response = await http.post(
      Uri.parse('https://nutify.site/api.php?action=notifyAppointees'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'appointment_id': appointmentId}),
    );
    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode == 200 && (data['error'] == false || data['success'] == true)) {
      return true;
    }
    final msg = (data['message'] ?? 'Failed to send notification');
    throw Exception(msg);
  }

  Future<bool?> _confirmNotifyDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 3,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_active, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Notify Appointees',
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Call both the student and the professor to this appointment now?',
                style: TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB000).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Notify',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetails(ModeratorHomeAppointments a) {
    // Format date
    String formattedDate = a.scheduleDate;
    try {
      final date = DateTime.parse(a.scheduleDate);
      formattedDate = DateFormat('MMMM d, y').format(date);
    } catch (_) {}

    // Format time
    String formattedTime = a.scheduleTime;
    try {
      if (a.scheduleTime.contains('-')) {
        var times = a.scheduleTime.split('-');
        final startTime = DateFormat('HH:mm:ss').parse(times[0].trim());
        final endTime = DateFormat('HH:mm:ss').parse(times[1].trim());
        formattedTime = '${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}';
      } else {
        final t = DateFormat('HH:mm:ss').parse(a.scheduleTime.trim());
        formattedTime = DateFormat('h:mm a').format(t);
      }
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.event_note, color: Color(0xFF35408E)),
                      SizedBox(width: 8),
                      Text(
                        'Appointment Details',
                        style: TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _detailRow('Professor', a.teacherName),
                  _detailRow('Student', a.studentName),
                  _detailRow('Date', formattedDate),
                  _detailRow('Time', formattedTime),
                  if (a.appointmentReason.isNotEmpty) _detailRow('Reason', a.appointmentReason),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 11,
              color: Colors.grey.shade700,
              letterSpacing: 0.7,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Arimo',
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnSpotRequestSheet extends StatefulWidget {
  final Future<void> Function(int teacherId, int studentId, String reason) onSubmitted;
  const _OnSpotRequestSheet({required this.onSubmitted});

  @override
  State<_OnSpotRequestSheet> createState() => _OnSpotRequestSheetState();
}

class _OnSpotRequestSheetState extends State<_OnSpotRequestSheet> {
  int? _teacherId;
  int? _studentId;
  String _teacherName = '';
  String _studentName = '';
  final TextEditingController _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _teacherId != null && _studentId != null && _reasonCtrl.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, -2)),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Create On-the-spot Request', style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),

              // Step 1: Faculty search
              const Text('Select Faculty', style: TextStyle(fontFamily: 'Arimo', fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 6),
              _SearchUserField(
                hint: 'Search faculty…',
                role: 'teacher',
                onSelected: (id, name) {
                  setState(() {
                    _teacherId = id;
                    _teacherName = name;
                  });
                },
              ),
              if (_teacherName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text('Selected: $_teacherName', style: const TextStyle(fontFamily: 'Arimo', color: Colors.green)),
                ),

              const SizedBox(height: 16),
              // Step 2: Student search
              const Text('Select Student', style: TextStyle(fontFamily: 'Arimo', fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 6),
              IgnorePointer(
                ignoring: _teacherId == null,
                child: Opacity(
                  opacity: _teacherId == null ? 0.5 : 1,
                  child: _SearchUserField(
                    hint: 'Search student…',
                    role: 'student',
                    onSelected: (id, name) {
                      setState(() {
                        _studentId = id;
                        _studentName = name;
                      });
                    },
                  ),
                ),
              ),
              if (_studentName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text('Selected: $_studentName', style: const TextStyle(fontFamily: 'Arimo', color: Colors.green)),
                ),

              const SizedBox(height: 16),
              // Step 3: Reason
              const Text('Reason', style: TextStyle(fontFamily: 'Arimo', fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 6),
              IgnorePointer(
                ignoring: _studentId == null,
                child: Opacity(
                  opacity: _studentId == null ? 0.5 : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _reasonCtrl,
                      onChanged: (_) => setState(() {}),
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Enter reason…',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(fontFamily: 'Arimo'),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: canSubmit
                              ? const [Color(0xFFFFD54F), Color(0xFFFFB300)]
                              : [Colors.grey.shade300, Colors.grey.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (canSubmit ? const Color(0xFFFFB000) : Colors.grey).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: canSubmit
                            ? () async {
                                final tid = _teacherId!;
                                final sid = _studentId!;
                                final reason = _reasonCtrl.text.trim();
                                await widget.onSubmitted(tid, sid, reason);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: Colors.transparent,
                        ),
                        child: Text(
                          'Schedule',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.bold,
                            color: canSubmit ? Colors.white : Colors.grey.shade600,
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
}

class _SearchUserField extends StatefulWidget {
  final String hint;
  final String role; // 'teacher' or 'student'
  final void Function(int id, String name) onSelected;
  const _SearchUserField({required this.hint, required this.role, required this.onSelected});

  @override
  State<_SearchUserField> createState() => _SearchUserFieldState();
}

class _SearchUserFieldState extends State<_SearchUserField> {
  final TextEditingController _ctrl = TextEditingController();
  List<_Option> _options = [];
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _options = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final uri = Uri.parse('https://nutify.site/api.php?action=searchUsers');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': q, 'role': widget.role}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['results'] ?? []) as List;
        setState(() {
          _options = list
              .map((e) => _Option(
                    id: int.tryParse(e['user_id']?.toString() ?? '') ?? 0,
                    name: (e['full_name'] ?? '${e['user_fn'] ?? ''} ${e['user_ln'] ?? ''}').trim(),
                  ))
              .toList();
        });
      } else {
        setState(() => _options = []);
      }
    } catch (_) {
      setState(() => _options = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _ctrl,
          onChanged: _search,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: widget.hint,
            hintStyle: const TextStyle(fontFamily: 'Arimo'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search),
          ),
          style: const TextStyle(fontFamily: 'Arimo'),
        ),
        const SizedBox(height: 8),
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        if (_options.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: _options.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final o = _options[i];
                return ListTile(
                  title: Text(o.name, style: const TextStyle(fontFamily: 'Arimo')),
                  onTap: () {
                    widget.onSelected(o.id, o.name);
                    setState(() {
                      _ctrl.text = o.name;
                      _options = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _Option {
  final int id;
  final String name;
  _Option({required this.id, required this.name});
}
