import 'package:flutter/material.dart';
import 'package:nutify/pages/studentHome.dart';
import 'package:nutify/pages/studentProfile.dart';
import 'package:nutify/models/studentInboxPending.dart';
import 'package:nutify/models/studentInboxCancelled.dart';
import 'package:nutify/models/studentInboxCompleted.dart';
import 'package:nutify/models/studentInboxMissed.dart';

class StudentInbox extends StatefulWidget {
  StudentInbox({super.key});

  @override
  _StudentInboxState createState() => _StudentInboxState();
}

class _StudentInboxState extends State<StudentInbox>
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
      appBar: studentAppBar(context),
      body: Column(
        children: [
          // Tab Bar
          navigationalTabs(),
          // Tab Bar View
          tabViews(),
        ],
      ),
    );
  }

  Expanded tabViews() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          // Pending Tab
          buildPendingTab(),
          // Cancelled Tab
          buildCancelledTab(),
          // Missed Tab
          buildMissedTab(),
          // Completed Tab
          buildCompletedTab(),
        ],
      ),
    );
  }

  Widget buildPendingTab() {
    return FutureBuilder<List<StudentInboxPending>>(
      future: StudentInboxPending.getStudentInboxPendings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        List<StudentInboxPending> pendingAppointments = snapshot.data ?? [];

        if (pendingAppointments.isEmpty) {
          return Center(
            child: Text(
              'No pending appointments',
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 16,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: pendingAppointments.length,
          itemBuilder: (context, index) {
            var appointment = pendingAppointments[index];
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
                              colors: [
                                Color(0xFF87CEEB), // Pastel sky blue
                                Color(0xFF4682B4), // Steel blue
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.pending, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.teacherName,
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
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getDarkerStatusColors('pending'),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: _getDarkerStatusColors('pending')[0].withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            print(
                              'View Details clicked for pending appointment ID: ${appointment.id}',
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
          },
        );
      },
    );
  }

  Widget buildCancelledTab() {
    return FutureBuilder<List<StudentInboxCancelled>>(
      future: StudentInboxCancelled.getStudentInboxCancelled(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        List<StudentInboxCancelled> cancelledAppointments = snapshot.data ?? [];

        if (cancelledAppointments.isEmpty) {
          return Center(
            child: Text(
              'No cancelled appointments',
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 16,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: cancelledAppointments.length,
          itemBuilder: (context, index) {
            var appointment = cancelledAppointments[index];
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
                              colors: [
                                Color(0xFFB22222), // Deep red
                                Color(0xFF8B0000), // Dark red
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.cancel, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.teacherName,
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
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getDarkerStatusColors('declined'),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: _getDarkerStatusColors('declined')[0].withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            print(
                              'View Details clicked for cancelled appointment ID: ${appointment.id}',
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
          },
        );
      },
    );
  }

  Widget buildMissedTab() {
    return FutureBuilder<List<StudentInboxMissed>>(
      future: StudentInboxMissed.getStudentInboxMissed(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        List<StudentInboxMissed> missedAppointments = snapshot.data ?? [];

        if (missedAppointments.isEmpty) {
          return Center(
            child: Text(
              'No missed appointments',
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 16,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: missedAppointments.length,
          itemBuilder: (context, index) {
            var appointment = missedAppointments[index];
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
                              colors: [
                                Color(0xFFFF8C00), // Yellow-orange
                                Color(0xFFFF4500), // Orange red
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.schedule, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.teacherName,
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
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getDarkerStatusColors('missed'),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: _getDarkerStatusColors('missed')[0].withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            print(
                              'View Details clicked for missed appointment ID: ${appointment.id}',
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
          },
        );
      },
    );
  }

  Widget buildCompletedTab() {
    return FutureBuilder<List<StudentInboxCompleted>>(
      future: StudentInboxCompleted.getStudentInboxCompleted(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        List<StudentInboxCompleted> completedAppointments = snapshot.data ?? [];

        if (completedAppointments.isEmpty) {
          return Center(
            child: Text(
              'No completed appointments',
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 16,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: completedAppointments.length,
          itemBuilder: (context, index) {
            var appointment = completedAppointments[index];
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
                              colors: [
                                Color(0xFF228B22), // Green
                                Color(0xFF006400), // Dark green
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_circle, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.teacherName,
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
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getDarkerStatusColors('completed'),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: _getDarkerStatusColors('completed')[0].withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            print(
                              'View Details clicked for completed appointment ID: ${appointment.id}',
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
          },
        );
      },
    );
  }

  // Helper method to get darker gradient colors for status buttons
  List<Color> _getDarkerStatusColors(String status) {
    switch (status) {
      case 'pending':
        return [Color(0xFF2196F3), Color(0xFF0D47A1)]; // Darker Blue
      case 'declined':
        return [Color(0xFFF44336), Color(0xFFB71C1C)]; // Darker Red
      case 'missed':
        return [Color(0xFFFF9800), Color(0xFFE65100)]; // Darker Orange
      case 'completed':
        return [Color(0xFF4CAF50), Color(0xFF2E7D32)]; // Darker Green
      default:
        return [Color(0xFF2196F3), Color(0xFF0D47A1)]; // Darker Blue
    }
  }

  Container navigationalTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Color(0xFFFFD418),
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: Color(0xFFFFD418),
        indicatorWeight: 3,
        labelStyle: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
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

  AppBar studentAppBar(BuildContext context) {
    return AppBar(
      title: Container(
        margin: const EdgeInsets.only(left: 10.0),
        child: const Text(
          'Student Inbox',
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
            // Check if already on StudentProfile page
            if (ModalRoute.of(context)?.settings.name == '/studentProfile') {
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
                  builder: (context) => StudentProfile(),
                  settings: RouteSettings(name: '/studentProfile'),
                ),
                (Route<dynamic> route) => false,
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(right: 25.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/icons/profile.png'),
              backgroundColor:
                  Colors.transparent, // Make sure the background is transparent
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
                  // Check if already on StudentHome page
                  if (ModalRoute.of(context)?.settings.name == '/studentHome') {
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
                        builder: (context) => StudentHome(),
                        settings: RouteSettings(name: '/studentHome'),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.inbox, color: Color(0xFFFFD418)),
                onPressed: () {
                  // Check if already on StudentInbox page
                  if (ModalRoute.of(context)?.settings.name ==
                          '/studentInbox' ||
                      context.widget.runtimeType == StudentInbox) {
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
                        builder: (context) => StudentInbox(),
                        settings: RouteSettings(name: '/studentInbox'),
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
