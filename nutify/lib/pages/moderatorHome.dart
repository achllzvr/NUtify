import 'package:flutter/material.dart';
import 'package:nutify/pages/moderatorProfile.dart';
import 'package:nutify/models/moderatorHomeAppointments.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildModeratorAppBar(context),
      body: _buildMainContent(),
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
                  // TODO: Replace with actual ModeratorInbox navigation when available
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Inbox page not implemented yet',
                        style: TextStyle(fontFamily: 'Arimo'),
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFF35408E),
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
        Expanded(
          child: FutureBuilder<List<ModeratorHomeAppointments>>(
            future: ModeratorHomeAppointments.getModeratorHomeAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              List<ModeratorHomeAppointments> appointments = snapshot.data ?? [];
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
              return ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: appointments.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  var appointment = appointments[index];
                  return _buildAppointmentCard(appointment);
                },
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
      builder: (ctx) => AlertDialog(
        title: Text('Notify Appointees', style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.bold)),
        content: Text('Call both the student and the professor to this appointment now?', style: TextStyle(fontFamily: 'Arimo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(fontFamily: 'Arimo', color: Colors.blueGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Notify', style: TextStyle(fontFamily: 'Arimo', color: Color(0xFF35408E), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(ModeratorHomeAppointments a) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event, color: Color(0xFF35408E)),
                  SizedBox(width: 8),
                  Text('Appointment Details', style: TextStyle(fontFamily: 'Arimo', fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 12),
              _detailRow('Professor', a.teacherName),
              _detailRow('Student', a.studentName),
              _detailRow('Date', a.scheduleDate),
              _detailRow('Time', a.scheduleTime),
              if (a.appointmentReason.isNotEmpty) _detailRow('Reason', a.appointmentReason),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text('$label:', style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.w600, color: Colors.grey[800]))),
          Expanded(child: Text(value, style: TextStyle(fontFamily: 'Arimo', color: Colors.black87))),
        ],
      ),
    );
  }
}
