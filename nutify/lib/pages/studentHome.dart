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
        SnackBar(content: Text('Failed to update status', style: TextStyle(fontFamily: 'Arimo', color: Colors.white)), backgroundColor: Colors.red),
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
            child: _isSearching
                ? searchResults()
                : FutureBuilder<List<RecentProfessor>>(
                    future: RecentProfessor.getRecentProfessors(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      
                      List<RecentProfessor> recentProfessors = snapshot.data ?? [];
                      return mainContent(recentProfessors);
                    },
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
                return _buildEmptyState('No upcoming appointments');
              }
              
              // Sort by start date/time ascending
              appointments.sort((a, b) {
                final da = _parseStartDateTime(a) ?? DateTime(2100);
                final db = _parseStartDateTime(b) ?? DateTime(2100);
                return da.compareTo(db);
              });

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: appointments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  var appointment = appointments[index];
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
                                  if (appointment.appointmentRemarks.isNotEmpty) ...[
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
                                colors: [Color(0xFFFFB000), Color(0xFFFF8F00)], // Darker Yellow/Orange
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
                                print('Viewing Details of Appointment: ${appointment.id}');
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
  builder: (_) => UpcomingSearchPage(
          initialFuture: _upcomingFuture,
        ),
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
          return DateTime(date.year, date.month, date.day, t.hour, t.minute, t.second);
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
            style: TextStyle(fontFamily: 'Arimo', fontSize: 14, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
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
                          showAppointmentRequestModal(context, professorName, idInt);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Invalid professor ID'), duration: Duration(seconds: 2)),
                          );
                        }
                      },
                      child: Container(
                        width: 140, // Made wider
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFF35408E), const Color(0xFF1A2049)],
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
        IconButton(
          tooltip: 'Refresh',
          onPressed: () {
            setState(() {
              _upcomingFuture = StudentHomeAppointments.getStudentHomeAppointments();
            });
          },
          icon: const Icon(Icons.refresh, color: Colors.white),
        ),
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
                icon: const Icon(Icons.inbox, color: Color(0xFFFFD418)),
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
    return Column(
      children: [
        mostRecentProfessors(recentProfessors),
  // Upcoming preview list (fixed height); full-screen search available via icon
  upcomingAppointments(),
      ],
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
        String initials = professor.name.split(' ').map((name) => name.isNotEmpty ? name[0] : '').take(2).join('').toUpperCase();
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
                        colors: [const Color(0xFF35408E), const Color(0xFF1A2049)],
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
                      colors: [const Color(0xFF35408E), const Color(0xFF1A2049)],
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
                        showAppointmentRequestModal(context, professorName, idInt);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invalid professor ID'), duration: Duration(seconds: 2)),
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

// Appointment Request Modal
void showAppointmentRequestModal(BuildContext context, String facultyName, int facultyId) async {
  print('[DEBUG] POSTING to fetchFacultySchedules with facultyId: $facultyId');
  List<Map<String, dynamic>> schedules = await fetchFacultySchedules(facultyId);
  print('[DEBUG] Schedules returned:');
  print(schedules);
  // Only consider schedules with status 'available'
  List<Map<String, dynamic>> availableSchedules = schedules.where((s) => (s['status'] ?? '').toLowerCase() == 'available').toList();
  print('[DEBUG] Available schedules:');
  print(availableSchedules);

  // Keep a reference to the root (caller) context to show nested pickers above the dialog
  final BuildContext rootContext = context;

  // Define the order of days for sorting
  const List<String> dayOrder = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  // Deduplicate and sort days based on dayOrder
  List<String> days = availableSchedules
      .map((s) => (s['day_of_week'] ?? s['day'] ?? '').toString())
      .where((d) => d.isNotEmpty)
      .toSet()
      .toList();
  days.sort((a, b) {
    int ia = dayOrder.indexOf(a);
    int ib = dayOrder.indexOf(b);
    if (ia == -1 && ib == -1) return a.compareTo(b);
    if (ia == -1) return 1;
    if (ib == -1) return -1;
    return ia.compareTo(ib);
  });
  print('[DEBUG] Days extracted from available schedules (deduped & sorted):');
  print(days);
  String selectedDay = days.isNotEmpty ? days[0] : '';
  int? selectedIndex;
  DateTime? selectedDate; // NEW: appointment calendar date matching selectedDay

  // Helper to map day name to weekday int (Mon=1..Sun=7)
  int _weekdayFromDayName(String day) {
    switch (day) {
      case 'Monday':
        return DateTime.monday;
      case 'Tuesday':
        return DateTime.tuesday;
      case 'Wednesday':
        return DateTime.wednesday;
      case 'Thursday':
        return DateTime.thursday;
      case 'Friday':
        return DateTime.friday;
      case 'Saturday':
        return DateTime.saturday;
      case 'Sunday':
        return DateTime.sunday;
      default:
        return -1;
    }
  }

  showDialog(
    context: rootContext,
    barrierDismissible: false,
    builder: (dialogContext) {
      final TextEditingController reasonController = TextEditingController();
      return StatefulBuilder(
        builder: (sbContext, setState) {
          // Filter available schedules for the selected day (exact match)
          List<Map<String, dynamic>> availableTimes = availableSchedules.where((s) {
            String day = (s['day_of_week'] ?? s['day'] ?? '').toString();
            return day == selectedDay;
          }).toList();

          // Button enabled only if a day is selected, there are available times, a schedule is selected,
          // a valid date matching the selected day is chosen, and a reason is provided
          bool isScheduleButtonEnabled = 
            selectedDay.isNotEmpty &&
            availableTimes.isNotEmpty &&
            selectedIndex != null &&
            selectedDate != null &&
            reasonController.text.trim().isNotEmpty;

          return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  // Title
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "$facultyName",
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 22,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "'s available schedules",
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontWeight: FontWeight.normal,
                            fontSize: 22,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Day Dropdown
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.white,
                        ),
                        child: DropdownButton<String>(
                          value: selectedDay,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down),
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          items: days.map((day) {
                            return DropdownMenuItem<String>(
                              value: day,
                              child: Text(day),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedDay = val!;
                              selectedIndex = null; // reset selected schedule for new day
                              selectedDate = null; // reset date since day changed
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Schedules available for the day
                  Text(
                    'Schedules available for the day:',
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    constraints: BoxConstraints(maxHeight: 220),
                    child: availableTimes.isEmpty
                        ? Center(
                            child: Text(
                              'No available schedules for this day.',
                              style: TextStyle(
                                fontFamily: 'Arimo',
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: availableTimes.length,
                            separatorBuilder: (context, idx) => SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              var sched = availableTimes[idx];
                              String start = formatTime(sched['start_time'] ?? sched['startTime']);
                              String end = formatTime(sched['end_time'] ?? sched['endTime']);
                              bool isSelected = selectedIndex == idx;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = idx;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 18),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Color(0xFFFFF8E1) : Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? Color(0xFFFFD418) : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$start - $end',
                                      style: TextStyle(
                                        fontFamily: 'Arimo',
                                        fontSize: 20,
                                        color: Color(0xFF283593),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  SizedBox(height: 16),
                  // NEW: Appointment Date selector (only dates matching selectedDay are enabled)
                  Text(
                    'Select Appointment Date:',
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            selectedDate == null
                                ? 'No date selected'
                                : '${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: selectedDay.isEmpty
                            ? null
                            : () async {
                                print('[DEBUG] Opening date picker');
                                final now = DateTime.now();
                                final first = DateTime(now.year, now.month, now.day);
                                final last = DateTime(now.year + 1, now.month, now.day);
                                final targetWeekday = _weekdayFromDayName(selectedDay);

                                // Ensure initialDate satisfies selectableDayPredicate
                                DateTime _nextMatchingWeekday(DateTime start, int weekday) {
                                  final int delta = (weekday - start.weekday) % 7;
                                  return start.add(Duration(days: delta));
                                }
                                final DateTime initial = selectedDate ?? _nextMatchingWeekday(first, targetWeekday);

                                final picked = await showDatePicker(
                                  context: rootContext,
                                  useRootNavigator: true,
                                  initialDate: initial,
                                  firstDate: first,
                                  lastDate: last,
                                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                                  selectableDayPredicate: (DateTime day) {
                                    // Only allow dates whose weekday matches selectedDay
                                    return day.weekday == targetWeekday;
                                  },
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
                                  setState(() => selectedDate = picked);
                                }
                              },
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

                  SizedBox(height: 16),
                  // Reason for Appointment Text Field
                  Text(
                    'Reason for Appointment:',
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: reasonController,
                      maxLines: 2,
                      minLines: 1,
                      onChanged: (val) {
                        setState(() {}); // Update button enabled state
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your reason...',
                        hintStyle: TextStyle(
                          fontFamily: 'Arimo',
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Use the dialog's context to pop the route to avoid deactivated ancestor errors
                            Navigator.of(dialogContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Schedule Button
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isScheduleButtonEnabled
                                ? LinearGradient(
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
                                color: isScheduleButtonEnabled
                                    ? Color(0xFFFFB000).withOpacity(0.25)
                                    : Colors.grey.withOpacity(0.15),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isScheduleButtonEnabled
                                ? () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    final String? studentIdStr = prefs.getString('userId');
                                    if (studentIdStr == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('User ID not found. Please log in again.')),
                                      );
                                      return;
                                    }
                                    final int studentId = int.tryParse(studentIdStr) ?? 0;
                                    if (studentId == 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Invalid user ID. Please log in again.')),
                                      );
                                      return;
                                    }
                                    int scheduleId = availableTimes[selectedIndex!]['schedule_id'];
                                    String reason = reasonController.text.trim();
                                    final String appointmentDate = '${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';

                                    if (scheduleId > 0 && reason.isNotEmpty) {
                                      var result = await postSetAppointment(
                                        studentId: studentId,
                                        teacherId: facultyId,
                                        scheduleId: scheduleId,
                                        reason: reason,
                                        appointmentDate: appointmentDate, // NEW
                                      );
                                      if (result['error'] == true) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(result['message'])),
                                        );
                                      } else {
                                        // Close dialog on success using the dialog context
                                        Navigator.of(dialogContext).pop();
                                        showRequestSnackBar(rootContext, 'Appointment request sent successfully!');
                                      }
                                    } else {
                                      showRequestSnackBarError(context, 'There was an error. Appointment could not be scheduled.');
                                    }
                                  } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: Colors.transparent,
                              disabledForegroundColor: Colors.white.withOpacity(0.5),
                            ),
                            child: Text(
                              'Schedule',
                              style: TextStyle(
                                fontFamily: 'Arimo',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isScheduleButtonEnabled ? Colors.white : Colors.grey.shade400,
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
          );
        },
      );
    },
  );
}

Future<List<Map<String, dynamic>>> fetchFacultySchedules(int facultyId) async {
  // Calls the backend API to fetch schedules for a teacher (facultyId)
  const String apiUrl = 'https://nutify.site/api.php?action=studentFetchTeacherSched';
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': facultyId.toString()}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        // Each item should have day_of_week, start_time, end_time, status, schedule_id, etc.
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data.containsKey('schedules')) {
        // Some APIs wrap in a 'schedules' key
        return List<Map<String, dynamic>>.from(data['schedules']);
      } else {
        return [];
      }
    } else {
      print('Failed to fetch schedules: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error fetching faculty schedules: $e');
    return [];
  }
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
  const String apiUrl = 'https://nutify.site/api.php?action=studentSetAppointment';
  try {
    // Include created_at from the app (current timestamp in MySQL DATETIME format)
    final now = DateTime.now();
    final createdAt = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
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
        'appointment_date': appointmentDate, // NEW field sent to backend (YYYY-MM-DD)
        'created_at': createdAt, // NEW: creation timestamp from app
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      return {
        'error': true,
        'message': 'Failed to set appointment: ${response.statusCode}'
      };
    }
  } catch (e) {
    return {
      'error': true,
      'message': 'Error: $e'
    };
  }
}

void showRequestSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          fontFamily: 'Arimo',
          color: Colors.white,
        ),
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
        style: TextStyle(
          fontFamily: 'Arimo',
          color: Colors.white,
        ),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: Color(0xFFDF0000),
    ),
  );
}