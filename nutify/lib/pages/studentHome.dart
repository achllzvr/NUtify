import 'package:flutter/material.dart';
import 'package:nutify/models/recentProfessorsModel.dart';
import 'package:nutify/models/studentHomeAppointments.dart';
import 'package:nutify/pages/studentInbox.dart';
import 'package:nutify/pages/studentProfile.dart';
import 'package:nutify/pages/login.dart';
import 'package:nutify/models/studentSearch.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutify/services/user_status_service.dart';
import 'package:intl/intl.dart';
import 'package:nutify/pages/_upcoming_search_page.dart';

class StudentHome extends StatefulWidget {
  StudentHome({super.key});

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _upcomingSearchCtrl = TextEditingController();
  List<StudentSearch> _searchResults = [];
  List<StudentSearch> _allProfessors = [];
  bool _isSearching = false;
  bool _isLoadingProfessors = true;
  Future<List<StudentHomeAppointments>>? _upcomingFuture;
  String _userStatus = 'online';
  bool _statusLoading = false;

  Future<void> _reloadHome() async {
    // Refresh both the professors list and upcoming appointments
    await _loadProfessors();
    final fut = StudentHomeAppointments.getStudentHomeAppointments();
    setState(() {
      _upcomingFuture = fut;
    });
    await fut;
  }

  @override
  void initState() {
    super.initState();
    _loadProfessors();
    _upcomingFuture = StudentHomeAppointments.getStudentHomeAppointments();
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
        SnackBar(
          content: Text(
            'Failed to update status',
            style: TextStyle(fontFamily: 'Arimo', color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadProfessors() async {
    try {
      List<StudentSearch> professors = await StudentSearch.searchProfessors();
      setState(() {
        _allProfessors = professors;
        _isLoadingProfessors = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProfessors = false;
      });
      print('Error loading professors: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _upcomingSearchCtrl.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _searchResults = [];
      } else {
        _isSearching = true;
        // Filter professors based on search query (name or department)
        _searchResults = _allProfessors.where((professor) {
          return professor.name.toLowerCase().contains(query.toLowerCase()) ||
              professor.department.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: studentAppBar(context),
      body: Column(
        children: [
          studentSearchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reloadHome,
              child: _isSearching
                  ? searchResults()
                  : FutureBuilder<List<RecentProfessor>>(
                      future: RecentProfessor.getRecentProfessors(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        List<RecentProfessor> recentProfessors =
                            snapshot.data ?? [];
                        return mainContent(recentProfessors);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget upcomingAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Upcoming Appointments...',
                style: TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF35408E)),
                tooltip: 'Search upcoming',
                onPressed: _openUpcomingSearch,
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 280,
          child: FutureBuilder<List<StudentHomeAppointments>>(
            future: _upcomingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              List<StudentHomeAppointments> appointments = snapshot.data ?? [];

              if (appointments.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _reloadHome,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      _buildEmptyState('No upcoming appointments'),
                    ],
                  ),
                );
              }

              // Sort by start date/time ascending
              appointments.sort((a, b) {
                final da = _parseStartDateTime(a) ?? DateTime(2100);
                final db = _parseStartDateTime(b) ?? DateTime(2100);
                return da.compareTo(db);
              });

              return RefreshIndicator(
                onRefresh: _reloadHome,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  itemCount: appointments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                  var appointment = appointments[index];
                  // Get initials for avatar
                  String initials = appointment.teacherName
                      .split(' ')
                      .map((name) => name.isNotEmpty ? name[0] : '')
                      .take(2)
                      .join('')
                      .toUpperCase();

                  // Generate color based on professor name
                  List<Color> avatarColors = [
                    Color(0xFF81C784), // Light green
                    Color(0xFFFFB74D), // Light orange
                    Color(0xFF9575CD), // Light purple
                    Color(0xFF4FC3F7), // Light blue
                    Color(0xFFFFD54F), // Light yellow
                    Color(0xFFFF8A65), // Light coral
                  ];
                  Color avatarColor =
                      avatarColors[appointment.teacherName.hashCode %
                          avatarColors.length];

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
                                    appointment.teacherName,
                                    style: TextStyle(
                                      fontFamily: 'Arimo',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '${appointment.scheduleDate} • ${appointment.scheduleTime}',
                                    style: TextStyle(
                                      fontFamily: 'Arimo',
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (appointment
                                      .appointmentReason
                                      .isNotEmpty) ...[
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
                                  if (appointment
                                      .appointmentRemarks
                                      .isNotEmpty) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      'Remarks: ${appointment.appointmentRemarks}',
                                      style: TextStyle(
                                        fontFamily: 'Arimo',
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
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
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFFB000),
                                  Color(0xFFFF8F00),
                                ], // Darker Yellow/Orange
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFFB000).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                print(
                                  'Viewing Details of Appointment: ${appointment.id}',
                                );
                                // TODO: Navigate to appointment details
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
                              child: Text(
                                'View Details',
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
                  );
                },
              ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openUpcomingSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => UpcomingSearchPage(initialFuture: _upcomingFuture),
      ),
    );
  }

  // Date/time parsers used for sorting and potential filters
  DateTime? _parseStartDateTime(StudentHomeAppointments a) {
    try {
      DateTime date;
      try {
        date = DateTime.parse(a.scheduleDate);
      } catch (_) {
        // Try 'MMMM d, y' or 'MMMM d'
        try {
          date = DateFormat('MMMM d, y').parseStrict(a.scheduleDate);
        } catch (_) {
          final now = DateTime.now();
          final md = DateFormat('MMMM d').parseStrict(a.scheduleDate);
          date = DateTime(now.year, md.month, md.day);
        }
      }
      String startStr = a.scheduleTime.contains('-')
          ? a.scheduleTime.split('-')[0].trim()
          : a.scheduleTime.trim();
      for (final fmt in ['HH:mm:ss', 'HH:mm', 'h:mm a', 'hh:mm a']) {
        try {
          final t = DateFormat(fmt).parseStrict(startStr);
          return DateTime(
            date.year,
            date.month,
            date.day,
            t.hour,
            t.minute,
            t.second,
          );
        } catch (_) {}
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Column mostRecentProfessors(List<RecentProfessor> recentProfessors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            'Your Most Recent Professors...',
            style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 120,
          child: recentProfessors.isEmpty
              ? Center(
                  child: Text(
                    'No recent professors',
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(width: 15),
                  padding: EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 10.0,
                    bottom: 10.0,
                  ),
                  itemCount: recentProfessors.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Show appointment request modal
                        String professorId = recentProfessors[index].id;
                        String professorName = recentProfessors[index].name;
                        int? idInt = int.tryParse(professorId);
                        if (idInt != null) {
                          showAppointmentRequestModal(
                            context,
                            professorName,
                            idInt,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Invalid professor ID'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 140, // Made wider
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF35408E),
                              const Color(0xFF1A2049),
                            ],
                            begin: const FractionalOffset(0.0, 0.0),
                            end: const FractionalOffset(0.0, 1.0),
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.25),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              recentProfessors[index].name,
                              style: TextStyle(
                                fontFamily: 'Arimo',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5),
                            Text(
                              recentProfessors[index].department,
                              style: TextStyle(
                                fontFamily: 'Arimo',
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Container studentSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _performSearch,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search Professor...',
          hintStyle: TextStyle(
            fontFamily: 'Arimo',
            color: Colors.grey,
            fontSize: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 10.0),
            child: Icon(Icons.search, color: Colors.grey),
          ),
          suffixIcon: _isSearching && _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  AppBar studentAppBar(BuildContext context) {
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
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
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
                    style: const TextStyle(
                      fontFamily: 'Arimo',
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Profile button
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
                  if (ModalRoute.of(context)?.settings.name == '/studentHome' ||
                      context.widget.runtimeType == StudentHome) {
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
                icon: const Icon(Icons.inbox, color: Colors.white),
                onPressed: () {
                  // Check if already on StudentInbox page
                  if (ModalRoute.of(context)?.settings.name ==
                      '/studentInbox') {
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

  Widget mainContent(List<RecentProfessor> recentProfessors) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          mostRecentProfessors(recentProfessors),
          // Upcoming preview list (fixed height); full-screen search available via icon
          upcomingAppointments(),
        ],
      ),
    );
  }

  Widget searchResults() {
    if (_isLoadingProfessors) {
      return Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 20),
            Text(
              'No professors found',
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching with a different name or department',
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(20.0),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => SizedBox(height: 15),
      itemBuilder: (context, index) {
        var professor = _searchResults[index];
        // Get initials for avatar
        String initials = professor.name
            .split(' ')
            .map((name) => name.isNotEmpty ? name[0] : '')
            .take(2)
            .join('')
            .toUpperCase();
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
                color: const Color.fromRGBO(0, 0, 0, 0.08),
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF35408E),
                          const Color(0xFF1A2049),
                        ],
                        begin: const FractionalOffset(0.0, 0.0),
                        end: const FractionalOffset(0.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 16,
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
                          professor.name,
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          professor.department,
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 14,
                            color: Colors.grey[600],
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
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF35408E),
                        const Color(0xFF1A2049),
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(0.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Show appointment request modal
                      String professorId = professor.id;
                      String professorName = professor.name;
                      int? idInt = int.tryParse(professorId);
                      if (idInt != null) {
                        showAppointmentRequestModal(
                          context,
                          professorName,
                          idInt,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invalid professor ID'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Set An Appointment',
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Appointment Request Modal (date-first flow with per-date capacity)
void showAppointmentRequestModal(
  BuildContext context,
  String facultyName,
  int facultyId,
) {
  final BuildContext rootContext = context;
  final TextEditingController reasonController = TextEditingController();

  DateTime? selectedDate; // chosen calendar date
  bool loading = false; // schedule fetch in progress
  List<Map<String, dynamic>> dateSchedules = []; // schedules returned for date
  int? selectedIndex; // which schedule chosen

  Future<void> _pickDate(StateSetter setState) async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final last = DateTime(now.year + 1, now.month, now.day);
    final picked = await showDatePicker(
      context: rootContext,
      useRootNavigator: true,
      initialDate: selectedDate ?? first,
      firstDate: first,
      lastDate: last,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (ctx, child) {
        final theme = Theme.of(rootContext);
        return Theme(
          data: theme.copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF35408E),
              secondary: Color(0xFFFFD418),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A2049),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF35408E),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        loading = true;
        selectedIndex = null;
        dateSchedules = [];
      });
      final dateStr = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      final fetched = await fetchFacultySchedules(facultyId, date: dateStr);
      setState(() {
        loading = false;
  // Show all schedules (including those with status 'booked' or full) so user can see why a slot is unavailable
  dateSchedules = fetched;
      });
    }
  }

  bool _isDisabledSlot(Map<String, dynamic> sched) {
    if (sched['day_of_week'] != null && sched['day_of_week'].toString().toUpperCase() == 'OTS') return false; // OTS exempt
    if (sched['is_full_for_date'] == true) return true;
    if (sched['is_full'] == true) return true; // fallback
    return false;
  }

  void _submit(StateSetter setState, BuildContext dialogContext) async {
    if (selectedDate == null || selectedIndex == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String? studentIdStr = prefs.getString('userId');
    if (studentIdStr == null) {
      showRequestSnackBarError(rootContext, 'User ID not found. Please log in again.');
      return;
    }
    final int studentId = int.tryParse(studentIdStr) ?? 0;
    if (studentId == 0) {
      showRequestSnackBarError(rootContext, 'Invalid user ID. Please log in again.');
      return;
    }
    final schedule = dateSchedules[selectedIndex!];
    final scheduleId = int.tryParse(schedule['schedule_id']?.toString() ?? schedule['id']?.toString() ?? '0') ?? 0;
    if (scheduleId <= 0) {
      showRequestSnackBarError(rootContext, 'Invalid schedule selected.');
      return;
    }
    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      showRequestSnackBarError(rootContext, 'Reason is required.');
      return;
    }
    final String appointmentDate = '${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
    setState(() => loading = true);
    final result = await postSetAppointment(
      studentId: studentId,
      teacherId: facultyId,
      scheduleId: scheduleId,
      reason: reason,
      appointmentDate: appointmentDate,
    );
    setState(() => loading = false);
    if ((result['success'] == false || result['error'] == true) && (result['code'] == 'FULL_FOR_DATE' || (result['message'] ?? '').toString().toLowerCase().contains('full'))) {
      showRequestSnackBarError(rootContext, 'Schedule is full for selected date.');
      // Refetch to reflect new state
      final fetched = await fetchFacultySchedules(facultyId, date: appointmentDate);
      setState(() {
  // After refetch, keep all schedules visible (no filtering by status)
  dateSchedules = fetched;
        selectedIndex = null;
      });
      return;
    }
    if (result['error'] == true || result['success'] == false) {
      showRequestSnackBarError(rootContext, (result['message'] ?? 'Failed to schedule').toString());
      return;
    }
    Navigator.of(dialogContext).pop();
    showRequestSnackBar(rootContext, 'Appointment request sent successfully!');
  }

  showDialog(
    context: rootContext,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (sbContext, setState) {
          final bool buttonEnabled = selectedDate != null && !loading && selectedIndex != null && reasonController.text.trim().isNotEmpty;
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: AnimatedPadding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(rootContext).viewInsets.bottom),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(24),
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
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: facultyName,
                              style: const TextStyle(
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 22,
                                color: Colors.black,
                              ),
                            ),
                            const TextSpan(
                              text: "'s schedules",
                              style: TextStyle(
                                fontFamily: 'Arimo',
                                fontSize: 22,
                                color: Colors.black,
                              ),
                            )
                          ]),
                        ),
                        const SizedBox(height: 24),
                        // Date selector first
                        const Text(
                          'Select Date:',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  selectedDate == null
                                      ? 'No date selected'
                                      : '${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontFamily: 'Arimo',
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: loading ? null : () => _pickDate(setState),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD418),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.event),
                              label: const Text(
                                'Pick date',
                                style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Schedules list (after date chosen)
                        if (selectedDate != null) ...[
                          Row(
                            children: [
                              const Text(
                                'Available Slots:',
                                style: TextStyle(
                                  fontFamily: 'Arimo',
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (loading) const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (loading)
                            _ScheduleSkeletonList()
                          else if (dateSchedules.isEmpty)
                            const Text(
                              'No available schedules for this date.',
                              style: TextStyle(fontFamily: 'Arimo', fontSize: 15, color: Colors.grey),
                            )
                          else
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 240),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: dateSchedules.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (c, idx) {
                                  final sched = dateSchedules[idx];
                                  final start = formatTime(sched['start_time'] ?? sched['startTime']);
                                  final end = formatTime(sched['end_time'] ?? sched['endTime']);
                                  final bool disabled = _isDisabledSlot(sched);
                                  final bool isSelected = selectedIndex == idx;
                                  final cap = int.tryParse(sched['capacity']?.toString() ?? '');
                                  final daily = int.tryParse(sched['daily_count']?.toString() ?? '');
                                  final remainingForDate = sched['remaining_for_date'] ?? sched['remaining'];
                                  final isFullForDate = sched['is_full_for_date'] == true || sched['is_full'] == true;
                                  return Opacity(
                                    opacity: disabled ? 0.55 : 1,
                                    child: GestureDetector(
                                      onTap: disabled
                                          ? null
                                          : () => setState(() => selectedIndex = idx),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFFFF8E1) : const Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFFFFD418) : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '$start - $end',
                                                    style: const TextStyle(
                                                      fontFamily: 'Arimo',
                                                      fontSize: 18,
                                                      color: Color(0xFF283593),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  if (cap != null && cap > 0) ...[
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        _capacityPill(
                                                          label: isFullForDate ? 'Full' : 'Remaining: ${remainingForDate ?? (cap - (daily ?? 0))}',
                                                          color: isFullForDate ? Colors.red.shade400 : const Color(0xFF283593),
                                                          bg: isFullForDate ? Colors.red.shade50 : const Color(0xFFE8EAF6),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        if (daily != null)
                                                          _capacityPill(
                                                            label: '${daily}/${cap}',
                                                            color: Colors.grey.shade700,
                                                            bg: Colors.grey.shade200,
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            if (isSelected && !disabled)
                                              const Icon(Icons.check_circle, color: Color(0xFFFFB300), size: 24),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                        const SizedBox(height: 20),
                        const Text(
                          'Reason for Appointment:',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: reasonController,
                            maxLines: 2,
                            minLines: 1,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Enter your reason...',
                              hintStyle: TextStyle(fontFamily: 'Arimo', color: Colors.grey, fontSize: 15),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontFamily: 'Arimo', fontSize: 15, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: loading ? null : () => Navigator.of(dialogContext).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontFamily: 'Arimo', fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: buttonEnabled
                                      ? const LinearGradient(
                                          colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: buttonEnabled ? const Color(0xFFFFB000).withOpacity(0.25) : Colors.grey.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: buttonEnabled ? () => _submit(setState, dialogContext) : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                    disabledBackgroundColor: Colors.transparent,
                                    disabledForegroundColor: Colors.white.withOpacity(0.5),
                                  ),
                                  child: Text(
                                    loading ? 'Scheduling...' : 'Schedule',
                                    style: TextStyle(
                                      fontFamily: 'Arimo',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: buttonEnabled ? Colors.white : Colors.grey.shade400,
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
              ),
            ),
          );
        },
      );
    },
  );
}

Future<List<Map<String, dynamic>>> fetchFacultySchedules(int facultyId, {String? date}) async {
  const String apiUrl = 'https://nutify.site/api.php?action=studentFetchTeacherSched';
  try {
    final body = <String, dynamic>{'id': facultyId.toString()};
    if (date != null) body['date'] = date; // new per-date parameter
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data.map(_augmentSchedule));
      } else if (data is Map && data.containsKey('schedules')) {
        return List<Map<String, dynamic>>.from((data['schedules'] as List).map(_augmentSchedule));
      }
    } else {
      print('Failed to fetch schedules: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching faculty schedules: $e');
  }
  return [];
}

Map<String, dynamic> _augmentSchedule(dynamic raw) {
  final map = Map<String, dynamic>.from(raw as Map);
  final cap = map['capacity'];
  int? capacity = cap == null ? null : int.tryParse(cap.toString());
  bool isCapacityMode = (capacity ?? 0) > 0;
  int? dailyCount = map['daily_count'] == null ? null : int.tryParse(map['daily_count'].toString());
  int remainingForDate = (dailyCount != null && capacity != null)
      ? (capacity - dailyCount).clamp(0, capacity)
      : (isCapacityMode ? capacity! : 0);
  map['is_capacity_mode'] = isCapacityMode;
  map['remaining_for_date'] = remainingForDate;
  map['remaining'] = remainingForDate; // backward compatibility with old UI code
  final bool isOTS = (map['day_of_week']?.toString().toUpperCase() == 'OTS');
  final bool fullByDate = isCapacityMode && remainingForDate <= 0 && !isOTS;
  map['is_full_for_date'] = fullByDate;
  map['is_full'] = fullByDate; // fallback flag
  return map;
}

// Simple skeleton placeholder list while fetching schedules
class _ScheduleSkeletonList extends StatelessWidget {
  const _ScheduleSkeletonList();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (i) => _ScheduleSkeleton()).expand((w) => [w, const SizedBox(height: 12)]).toList()..removeLast(),
    );
  }
}

class _ScheduleSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 140, height: 16),
                const SizedBox(height: 8),
                _shimmerBox(width: 90, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _shimmerBox(width: 24, height: 24, radius: 12),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

Widget _capacityPill({required String label, required Color color, required Color bg}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: 'Arimo',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
      ),
    ),
  );
}

// Helper: format time (HH:mm or HH:mm:ss to h:mm)
String formatTime(String? time) {
  if (time == null) return '';
  try {
    final parts = time.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    String ampm = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${hour12}:${minute.toString().padLeft(2, '0')} $ampm';
  } catch (_) {
    return time;
  }
}

Future<Map<String, dynamic>> postSetAppointment({
  required int studentId,
  required int teacherId,
  required int scheduleId,
  required String reason,
  required String appointmentDate, // NEW param
}) async {
  const String apiUrl =
      'https://nutify.site/api.php?action=studentSetAppointment';
  try {
    // Include created_at from the app (current timestamp in MySQL DATETIME format)
    final now = DateTime.now();
    final createdAt =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        'Accept': 'application/json',
      },
      body: {
        'studentID': studentId.toString(),
        'teacherID': teacherId.toString(),
        'schedule_id': scheduleId.toString(),
        'appointment_reason': reason,
        'appointment_date':
            appointmentDate, // NEW field sent to backend (YYYY-MM-DD)
        'created_at': createdAt, // NEW: creation timestamp from app
      },
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      // Intercept capacity race condition message
      if (decoded['error'] == true && (decoded['message'] ?? '').toString().toLowerCase().contains('schedule is full')) {
        decoded['capacity_full'] = true;
      }
      return decoded;
    } else {
      return {
        'error': true,
        'message': 'Failed to set appointment: ${response.statusCode}',
      };
    }
  } catch (e) {
    return {'error': true, 'message': 'Error: $e'};
  }
}

void showRequestSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(fontFamily: 'Arimo', color: Colors.white),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: Color(0xFF00FD0F),
    ),
  );
}

void showRequestSnackBarError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(fontFamily: 'Arimo', color: Colors.white),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: Color(0xFFDF0000),
    ),
  );
}