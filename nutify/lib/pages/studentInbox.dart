import 'package:flutter/material.dart';
import 'package:nutify/pages/studentHome.dart';
import 'package:nutify/pages/studentProfile.dart';
import 'package:nutify/models/studentInboxPending.dart';
import 'package:nutify/models/studentInboxCancelled.dart';
import 'package:nutify/models/studentInboxCompleted.dart';
import 'package:nutify/models/studentInboxMissed.dart';
import 'package:nutify/services/user_status_service.dart';

class StudentInbox extends StatefulWidget {
  StudentInbox({super.key});

  @override
  _StudentInboxState createState() => _StudentInboxState();
}

class _StudentInboxState extends State<StudentInbox>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Global and per-tab search controllers
  final TextEditingController _globalCtrl = TextEditingController();
  final TextEditingController _pendingCtrl = TextEditingController();
  final TextEditingController _declinedCtrl = TextEditingController();
  final TextEditingController _missedCtrl = TextEditingController();
  final TextEditingController _completedCtrl = TextEditingController();
  String _globalQ = '', _pendingQ = '', _declinedQ = '', _missedQ = '', _completedQ = '';
  String _userStatus = 'online';
  bool _statusLoading = false;

  Future<void> _reloadInbox() async {
    // Kick all fetchers and then rebuild
    final f1 = StudentInboxPending.getStudentInboxPendings();
    final f2 = StudentInboxCancelled.getStudentInboxCancelled();
    final f3 = StudentInboxMissed.getStudentInboxMissed();
    final f4 = StudentInboxCompleted.getStudentInboxCompleted();
    await Future.wait([f1, f2, f3, f4]);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  _initUserStatus();
  _globalCtrl.addListener(() { final v = _globalCtrl.text; if (v != _globalQ) setState(() => _globalQ = v); });
  _pendingCtrl.addListener(() { final v = _pendingCtrl.text; if (v != _pendingQ) setState(() => _pendingQ = v); });
  _declinedCtrl.addListener(() { final v = _declinedCtrl.text; if (v != _declinedQ) setState(() => _declinedQ = v); });
  _missedCtrl.addListener(() { final v = _missedCtrl.text; if (v != _missedQ) setState(() => _missedQ = v); });
  _completedCtrl.addListener(() { final v = _completedCtrl.text; if (v != _completedQ) setState(() => _completedQ = v); });
  }

  @override
  void dispose() {
  _tabController.dispose();
  _globalCtrl.dispose();
  _pendingCtrl.dispose();
  _declinedCtrl.dispose();
  _missedCtrl.dispose();
  _completedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: studentAppBar(context),
      body: Column(
        children: [
          // Global search (all tabs)
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _globalCtrl,
                decoration: InputDecoration(
                  hintText: 'Search across all tabs...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
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

        // Per-tab search bar
        final tabSearch = Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _pendingCtrl,
            decoration: InputDecoration(
              hintText: 'Search pending...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );

        final q = (_globalQ + ' ' + _pendingQ).trim().toLowerCase();
        if (q.isNotEmpty) {
          pendingAppointments = pendingAppointments.where((a) =>
            a.teacherName.toLowerCase().contains(q) ||
            a.department.toLowerCase().contains(q) ||
            a.scheduleDate.toLowerCase().contains(q) ||
            a.scheduleTime.toLowerCase().contains(q) ||
            a.appointmentReason.toLowerCase().contains(q) ||
            a.appointmentRemarks.toLowerCase().contains(q)
          ).toList();
        }

        if (pendingAppointments.isEmpty) {
          return Column(children: [
            tabSearch,
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reloadInbox,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    _buildEmptyState('No pending appointments'),
                  ],
                ),
              ),
            ),
          ]);
        }

        return Column(
          children: [
            tabSearch,
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reloadInbox,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            _showStudentAppointmentDetails(
                              status: 'pending',
                              appointmentId: appointment.id,
                              name: appointment.teacherName,
                              department: appointment.department,
                              date: appointment.scheduleDate,
                              time: appointment.scheduleTime,
                              reason: appointment.appointmentReason,
                              remarks: appointment.appointmentRemarks,
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
                ),
              ),
            ),
          ],
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

        final tabSearch = Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _declinedCtrl,
            decoration: InputDecoration(
              hintText: 'Search declined...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );

        final q = (_globalQ + ' ' + _declinedQ).trim().toLowerCase();
        if (q.isNotEmpty) {
          cancelledAppointments = cancelledAppointments.where((a) =>
            a.teacherName.toLowerCase().contains(q) ||
            a.department.toLowerCase().contains(q) ||
            a.scheduleDate.toLowerCase().contains(q) ||
            a.scheduleTime.toLowerCase().contains(q) ||
            a.appointmentReason.toLowerCase().contains(q) ||
            a.appointmentRemarks.toLowerCase().contains(q)
          ).toList();
        }

        if (cancelledAppointments.isEmpty) {
          return Column(children: [
            tabSearch,
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reloadInbox,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    _buildEmptyState('No declined appointments'),
                  ],
                ),
              ),
            ),
          ]);
        }

        return Column(
          children: [
            tabSearch,
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reloadInbox,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            _showStudentAppointmentDetails(
                              status: 'declined',
                              appointmentId: appointment.id,
                              name: appointment.teacherName,
                              department: appointment.department,
                              date: appointment.scheduleDate,
                              time: appointment.scheduleTime,
                              reason: appointment.appointmentReason,
                              remarks: appointment.appointmentRemarks,
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
                ),
              ),
            ),
          ],
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

        final tabSearch = Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _missedCtrl,
            decoration: InputDecoration(
              hintText: 'Search missed...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );

        final q = (_globalQ + ' ' + _missedQ).trim().toLowerCase();
        if (q.isNotEmpty) {
          missedAppointments = missedAppointments.where((a) =>
            a.teacherName.toLowerCase().contains(q) ||
            a.department.toLowerCase().contains(q) ||
            a.scheduleDate.toLowerCase().contains(q) ||
            a.scheduleTime.toLowerCase().contains(q) ||
            a.appointmentReason.toLowerCase().contains(q) ||
            a.appointmentRemarks.toLowerCase().contains(q)
          ).toList();
        }

        if (missedAppointments.isEmpty) {
          return Column(children: [
            tabSearch,
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reloadInbox,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    _buildEmptyState('No missed appointments'),
                  ],
                ),
              ),
            ),
          ]);
        }

        return Column(
          children: [
            tabSearch,
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reloadInbox,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            _showStudentAppointmentDetails(
                              status: 'missed',
                              appointmentId: appointment.id,
                              name: appointment.teacherName,
                              department: appointment.department,
                              date: appointment.scheduleDate,
                              time: appointment.scheduleTime,
                              reason: appointment.appointmentReason,
                              remarks: appointment.appointmentRemarks,
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
                ),
              ),
            ),
          ],
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

        final tabSearch = Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _completedCtrl,
            decoration: InputDecoration(
              hintText: 'Search completed...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );

        final q = (_globalQ + ' ' + _completedQ).trim().toLowerCase();
        if (q.isNotEmpty) {
          completedAppointments = completedAppointments.where((a) =>
            a.teacherName.toLowerCase().contains(q) ||
            a.department.toLowerCase().contains(q) ||
            a.scheduleDate.toLowerCase().contains(q) ||
            a.scheduleTime.toLowerCase().contains(q) ||
            a.appointmentReason.toLowerCase().contains(q) ||
            a.appointmentRemarks.toLowerCase().contains(q)
          ).toList();
        }

        if (completedAppointments.isEmpty) {
          return Column(children: [
            tabSearch,
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reloadInbox,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    _buildEmptyState('No completed appointments'),
                  ],
                ),
              ),
            ),
          ]);
        }

        return Column(
          children: [
            tabSearch,
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reloadInbox,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            _showStudentAppointmentDetails(
                              status: 'completed',
                              appointmentId: appointment.id,
                              name: appointment.teacherName,
                              department: appointment.department,
                              date: appointment.scheduleDate,
                              time: appointment.scheduleTime,
                              reason: appointment.appointmentReason,
                              remarks: appointment.appointmentRemarks,
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
                ),
              ),
            ),
          ],
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
        // Presence toggle
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
                icon: const Icon(Icons.home, color: Colors.white),
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

  // Shared helpers
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

  void _showStudentAppointmentDetails({
    required String status,
    required String appointmentId,
    required String name,
    required String department,
    required String date,
    required String time,
    String? reason,
    String? remarks,
  }) {
    final colors = _getDarkerStatusColors(status);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: colors),
                    ),
                    child: const Icon(Icons.info, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Appointment Details',
                      style: TextStyle(fontFamily: 'Arimo', fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Status chip
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text('Status',
                        style: TextStyle(
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        )),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors[0].withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors[0].withOpacity(0.35)),
                    ),
                    child: Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors[0],
                      ),
                    ),
                  ),
                ],
              ),
              _kv('Appointment ID', appointmentId),
              _kv('Professor', name),
              _kv('Department', department),
              _kv('Date', date),
              _kv('Time', time),
              if (reason != null && reason.trim().isNotEmpty) _kv('Reason', reason.trim()),
              if (remarks != null && remarks.trim().isNotEmpty) _kv('Remarks', remarks.trim()),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF35408E), Color(0xFF1A2049)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF35408E).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Close', style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(k,
                style: TextStyle(
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
                )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              v,
        style: const TextStyle(fontFamily: 'Arimo', fontSize: 14, color: Color(0xFF2C3E50)),
            ),
          ),
        ],
      ),
    );
  }
}
