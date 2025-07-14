import 'package:flutter/material.dart';
import 'package:nutify/models/recentProfessorsModel.dart';
import 'package:nutify/models/studentHomeAppointments.dart';
import 'package:nutify/pages/studentInbox.dart';
import 'package:nutify/pages/studentProfile.dart';
import 'package:nutify/pages/login.dart';
import 'package:nutify/models/studentSearch.dart';

class StudentHome extends StatefulWidget {
  StudentHome({super.key});

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final TextEditingController _searchController = TextEditingController();
  List<StudentSearch> _searchResults = [];
  List<StudentSearch> _allProfessors = [];
  bool _isSearching = false;
  bool _isLoadingProfessors = true;

  @override
  void initState() {
    super.initState();
    _loadProfessors();
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
          child: FutureBuilder<List<StudentHomeAppointments>>(
            future: StudentHomeAppointments.getStudentHomeAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              List<StudentHomeAppointments> appointments = snapshot.data ?? [];
              
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
                padding: EdgeInsets.all(20.0),
                itemCount: appointments.length,
                separatorBuilder: (context, index) => SizedBox(height: 15),
                itemBuilder: (context, index) {
                  var appointment = appointments[index];
                  // Get initials for avatar
                  String initials = appointment.name.split(' ').map((name) => name.isNotEmpty ? name[0] : '').take(2).join('').toUpperCase();
                  
                  // Generate color based on professor name
                  List<Color> avatarColors = [
                    Color(0xFF81C784), // Light green
                    Color(0xFFFFB74D), // Light orange  
                    Color(0xFF9575CD), // Light purple
                    Color(0xFF4FC3F7), // Light blue
                    Color(0xFFFFD54F), // Light yellow
                    Color(0xFFFF8A65), // Light coral
                  ];
                  Color avatarColor = avatarColors[appointment.name.hashCode % avatarColors.length];
                  
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
                                    appointment.name,
                                    style: TextStyle(
                                      fontFamily: 'Arimo',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '${appointment.scheduleDate} ${appointment.scheduleTime}',
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
                                colors: [Color(0xFFFFD418), Color(0xFFFFE566)],
                                begin: const FractionalOffset(0.0, 0.0),
                                end: const FractionalOffset(0.0, 1.0),
                                stops: [0.0, 1.0],
                                tileMode: TileMode.clamp,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
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
                        // Access the professor ID here
                        String professorId = recentProfessors[index].id;
                        String professorName = recentProfessors[index].name;
                        print('Professor ID: $professorId, Name: $professorName');
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
          'Student Home',
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
        Expanded(child: upcomingAppointments()),
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
                      // Access the professor ID here
                      String professorId = professor.id;
                      String professorName = professor.name;
                      print('Setting appointment with Professor ID: $professorId, Name: $professorName');
                      // TODO: Navigate to appointment booking page
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
