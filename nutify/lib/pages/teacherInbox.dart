import 'package:flutter/material.dart';
import 'package:nutify/pages/teacherHome.dart';
import 'package:nutify/pages/teacherProfile.dart';
import 'package:nutify/models/teacherInboxPending.dart';
import 'package:nutify/models/teacherInboxCancelled.dart';
import 'package:nutify/models/teacherInboxCompleted.dart';
import 'package:nutify/models/teacherInboxMissed.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherInbox extends StatefulWidget {
  TeacherInbox({super.key});

  @override
  _TeacherInboxState createState() => _TeacherInboxState();
}

class _TeacherInboxState extends State<TeacherInbox>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? teacherUserId;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTeacherUserId();
  }


  Future<void> _loadTeacherUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      teacherUserId = prefs.getString('userId');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildTeacherAppBar(context),
      body: Column(
        children: [
          _buildNavigationalTabs(),
          _buildTabViews(),
        ],
      ),
    );
  }

  Widget _buildNavigationalTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Color(0xFFFFD418),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xFFFFD418),
        indicatorWeight: 3,
        labelStyle: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: [
          Tab(text: 'Pending'),
          Tab(text: 'Declined'),
          Tab(text: 'Missed'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildTabViews() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildDeclinedTab(),
          _buildMissedTab(),
          _buildCompletedTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    return FutureBuilder<List<TeacherInboxPending>>(
      future: TeacherInboxPending.getTeacherInboxPendings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        List<TeacherInboxPending> pendingAppointments = snapshot.data ?? [];

        if (pendingAppointments.isEmpty) {
          return _buildEmptyState('No pending appointments');
        }

        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: pendingAppointments.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            var appointment = pendingAppointments[index];
            return _buildAppointmentCard(
              appointment.studentName,
              appointment.department,
              appointment.scheduleDate,
              appointment.scheduleTime,
              'pending',
              appointment.id,
              appointment.appointmentReason,
            );
          },
        );
      },
    );
  }

  Widget _buildDeclinedTab() {
    return FutureBuilder<List<TeacherInboxCancelled>>(
      future: TeacherInboxCancelled.getTeacherInboxCancelleds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        List<TeacherInboxCancelled> declinedAppointments = snapshot.data ?? [];

        if (declinedAppointments.isEmpty) {
          return _buildEmptyState('No declined appointments');
        }

        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: declinedAppointments.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            var appointment = declinedAppointments[index];
            return _buildAppointmentCard(
              appointment.studentName,
              appointment.department,
              appointment.scheduleDate,
              appointment.scheduleTime,
              'declined',
              appointment.id,
              appointment.appointmentReason,
            );
          },
        );
      },
    );
  }

  Widget _buildMissedTab() {
    return FutureBuilder<List<TeacherInboxMissed>>(
      future: TeacherInboxMissed.getTeacherInboxMisseds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        List<TeacherInboxMissed> missedAppointments = snapshot.data ?? [];

        if (missedAppointments.isEmpty) {
          return _buildEmptyState('No missed appointments');
        }

        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: missedAppointments.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            var appointment = missedAppointments[index];
            return _buildAppointmentCard(
              appointment.studentName,
              appointment.department,
              appointment.scheduleDate,
              appointment.scheduleTime,
              'missed',
              appointment.id,
              appointment.appointmentReason,
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedTab() {
    return FutureBuilder<List<TeacherInboxCompleted>>(
      future: TeacherInboxCompleted.getTeacherInboxCompleteds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        List<TeacherInboxCompleted> completedAppointments = snapshot.data ?? [];

        if (completedAppointments.isEmpty) {
          return _buildEmptyState('No completed appointments');
        }

        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: completedAppointments.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            var appointment = completedAppointments[index];
            return _buildAppointmentCard(
              appointment.studentName,
              appointment.department,
              appointment.scheduleDate,
              appointment.scheduleTime,
              'completed',
              appointment.id,
              appointment.appointmentReason,
            );
          },
        );
      },
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
                        _getStatusColors(status)[0].withOpacity(0.1),
                        _getStatusColors(status)[1].withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    color: _getStatusColors(status)[0],
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
                            colors: [_getStatusColors(status)[0], _getStatusColors(status)[1]],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColors(status)[0].withOpacity(0.4),
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

  // Helper method to get status colors for dialogs
  List<Color> _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return [Color(0xFF87CEEB), Color(0xFF4682B4)]; // Blue
      case 'declined':
        return [Color(0xFFFFB74D), Color(0xFFFF8A65)]; // Orange
      case 'completed':
        return [Color(0xFF4CAF50), Color(0xFF2E7D32)]; // Green
      case 'missed':
        return [Color(0xFFF44336), Color(0xFFB71C1C)]; // Red
      default:
        return [Color(0xFF87CEEB), Color(0xFF4682B4)]; // Default blue
    }
  }

  // Helper method to get status icons for dialogs
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_outline;
      case 'declined':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.task_alt_outlined;
      case 'missed':
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 16,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    String studentName,
    String department,
    String scheduleDate,
    String scheduleTime,
    String status,
    String appointmentId,
    String? appointmentReason,
  ) {
    // Get initials for avatar
    String initials = studentName.split(' ').map((name) => name.isNotEmpty ? name[0] : '').take(2).join('').toUpperCase();
    
    // Get status-specific icon and colors
    IconData statusIcon;
    List<Color> statusColors;
    
    switch (status) {
      case 'pending':
        statusIcon = Icons.pending;
        statusColors = [Color(0xFF87CEEB), Color(0xFF4682B4)]; // Sky blue
        break;
      case 'declined':
        statusIcon = Icons.cancel;
        statusColors = [Color(0xFFFFB74D), Color(0xFFFF8A65)]; // Orange
        break;
      case 'missed':
        statusIcon = Icons.error;
        statusColors = [Color(0xFFFF8A80), Color(0xFFE57373)]; // Red
        break;
      case 'completed':
        statusIcon = Icons.check_circle;
        statusColors = [Color(0xFF81C784), Color(0xFF66BB6A)]; // Green
        break;
      default:
        statusIcon = Icons.info;
        statusColors = [Color(0xFF87CEEB), Color(0xFF4682B4)];
    }

    return GestureDetector(
      onTap: () {
        print('Card clicked for $status appointment ID: $appointmentId');
        // TODO: Navigate to appointment details
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
                        colors: statusColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studentName,
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          department,
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '$scheduleDate • $scheduleTime',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (appointmentReason != null && appointmentReason.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            'Reason: $appointmentReason',
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
              // Show different buttons based on status
              if (status == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF87CEEB), Color(0xFF4682B4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF87CEEB).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            _showStatusConfirmationDialog(
                              context,
                              'accepted',
                              appointmentId,
                              () async {
                                final result = await _updateAppointmentStatus(appointmentId, 'accepted', teacherUserId!);
                                if (result['error'] == false) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Appointment marked as accepted!', style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
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
                            'Accept',
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
                            colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)], // Same orange as declined card
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFB74D).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            _showStatusConfirmationDialog(
                              context,
                              'declined',
                              appointmentId,
                              () async {
                                final result = await _updateAppointmentStatus(appointmentId, 'declined', teacherUserId!);
                                if (result['error'] == false) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Appointment marked as declined!', style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
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
                            'Decline',
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
                )
              else
                // Show view details button for non-pending appointments
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getDarkerStatusColors(status),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: _getDarkerStatusColors(status)[0].withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            print('View Details clicked for $status appointment ID: $appointmentId');
                            // TODO: Navigate to appointment details
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
                            'View Details',
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

  // Helper method to get darker gradient colors for status buttons
  List<Color> _getDarkerStatusColors(String status) {
    switch (status) {
      case 'declined':
        return [Color(0xFFFF9800), Color(0xFFE65100)]; // Darker Orange
      case 'missed':
        return [Color(0xFFF44336), Color(0xFFB71C1C)]; // Darker Red
      case 'completed':
        return [Color(0xFF4CAF50), Color(0xFF2E7D32)]; // Darker Green
      default:
        return [Color(0xFF2196F3), Color(0xFF0D47A1)]; // Darker Blue
    }
  }

  AppBar _buildTeacherAppBar(BuildContext context) {
    return AppBar(
      title: Container(
        margin: const EdgeInsets.only(left: 10.0),
        child: const Text(
          'Inbox',
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
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name == '/teacherHome') {
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
                icon: const Icon(Icons.inbox, color: Color(0xFFFFD418)),
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name == '/teacherInbox' ||
                      context.widget.runtimeType == TeacherInbox) {
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

Future<Map<String, dynamic>> _updateAppointmentStatus(
    String appointmentId, String status, String facultyId) async {
  // Map status to API action
  String action;
  switch (status) {
    case 'accepted':
      action = 'updateAppStatusA';
      break;
    case 'declined':
      action = 'updateAppStatusD';
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