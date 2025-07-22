import 'package:flutter/material.dart';
import 'package:nutify/pages/teacherInbox.dart';
import 'package:nutify/pages/teacherProfile.dart';
import 'package:nutify/models/teacherHomeAppointments.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TeacherHome extends StatefulWidget {
  TeacherHome({super.key});

  @override
  _TeacherHomeState createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildTeacherAppBar(context),
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Expanded(
          child: _buildUpcomingAppointments(),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            'Your Upcoming Appointments...',
            style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 5),
        Expanded(
          child: FutureBuilder<List<TeacherHomeAppointments>>(
            future: TeacherHomeAppointments.getTeacherHomeAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              List<TeacherHomeAppointments> appointments = snapshot.data ?? [];
              
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
                  // Since API now only returns accepted appointments, use the main card
                  return _buildAppointmentCard(appointment);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(TeacherHomeAppointments appointment) {
    // Get initials for avatar
    String initials = appointment.studentName.split(' ').map((name) => name.isNotEmpty ? name[0] : '').take(2).join('').toUpperCase();
    
    return GestureDetector(
      onTap: () {
        print('Accepted appointment ID: ${appointment.id}');
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
                        onPressed: () async {
                          _showStatusConfirmationDialog(
                            context,
                            'completed',
                            appointment.id,
                            () async {
                              final result = await _updateAppointmentStatus(appointment.id, 'completed');
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
                        onPressed: () async {
                          _showStatusConfirmationDialog(
                            context,
                            'missed',
                            appointment.id,
                            () async{
                              final result = await _updateAppointmentStatus(appointment.id, 'missed');
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
}

Future<Map<String, dynamic>> _updateAppointmentStatus(String appointmentId, String status) async {
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
    body: jsonEncode({'appointment_id': appointmentId}),
  );
  return jsonDecode(response.body);
}