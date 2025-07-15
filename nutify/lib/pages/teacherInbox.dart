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
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Tab(text: 'Cancelled'),
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
          _buildCancelledTab(),
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
              appointment.faculty,
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

  Widget _buildCancelledTab() {
    return FutureBuilder<List<TeacherInboxCancelled>>(
      future: TeacherInboxCancelled.getTeacherInboxCancelleds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        List<TeacherInboxCancelled> cancelledAppointments = snapshot.data ?? [];

        if (cancelledAppointments.isEmpty) {
          return _buildEmptyState('No cancelled appointments');
        }

        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: cancelledAppointments.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            var appointment = cancelledAppointments[index];
            return _buildAppointmentCard(
              appointment.studentName,
              appointment.faculty,
              appointment.scheduleDate,
              appointment.scheduleTime,
              'cancelled',
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
              appointment.faculty,
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
              appointment.faculty,
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
    String faculty,
    String scheduleDate,
    String scheduleTime,
    String status,
    String appointmentId,
  ) {
    // Get initials for avatar
    String initials = studentName.split(' ').map((name) => name.isNotEmpty ? name[0] : '').take(2).join('').toUpperCase();
    
    // Generate color based on student name
    List<Color> avatarColors = [
      Color(0xFF81C784), // Light green
      Color(0xFFFFB74D), // Light orange  
      Color(0xFF9575CD), // Light purple
      Color(0xFF4FC3F7), // Light blue
      Color(0xFFFFD54F), // Light yellow
      Color(0xFFFF8A65), // Light coral
    ];
    Color avatarColor = avatarColors[studentName.hashCode % avatarColors.length];

    return Container(
      padding: EdgeInsets.all(20),
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
                      studentName,
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Faculty - $faculty',
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '$scheduleDate - $scheduleTime',
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 14,
                        color: Color(0xFF35408E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () {
                  print('Viewing Details of $status Appointment: $appointmentId');
                  // TODO: Navigate to appointment details
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'See More',
                  style: TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildTeacherAppBar(BuildContext context) {
    return AppBar(
      title: Container(
        margin: const EdgeInsets.only(left: 10.0),
        child: const Text(
          'History',
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
                          'You are already on the History page',
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