import 'package:flutter/material.dart';
import 'package:nutify/pages/teacherHome.dart';
import 'package:nutify/pages/teacherProfile.dart';
import 'package:nutify/models/teacherInboxPending.dart';
import 'package:nutify/models/teacherInboxCancelled.dart';
import 'package:nutify/models/teacherInboxCompleted.dart';
import 'package:nutify/models/teacherInboxMissed.dart';

class TeacherInbox extends StatefulWidget {
  TeacherInbox({super.key});

  @override
  _TeacherInboxState createState() => _TeacherInboxState();
}

class _TeacherInboxState extends State<TeacherInbox>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
            );
          },
        );
      },
    );
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

    return Card(
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
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: statusColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
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
      ),
    );
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