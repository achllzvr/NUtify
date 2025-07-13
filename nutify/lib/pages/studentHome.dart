import 'package:flutter/material.dart';
import 'package:nutify/models/recentProfessorsModel.dart';
import 'package:nutify/models/studentHomeAppointments.dart';
import 'package:nutify/pages/studentInbox.dart';
import 'package:nutify/pages/studentProfile.dart';
import 'package:nutify/models/studentSearch.dart';

class StudentHome extends StatefulWidget {
  StudentHome({super.key});

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final TextEditingController _searchController = TextEditingController();
  List<StudentSearch> _searchResults = [];
  bool _isSearching = false;

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
        // Get all professors from StudentSearch model
        List<StudentSearch> allProfessors = StudentSearch.searchProfessors();
        
        // Filter professors based on search query (name or department)
        _searchResults = allProfessors.where((professor) {
          return professor.name.toLowerCase().contains(query.toLowerCase()) ||
                 professor.department.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the recent professors data
    List<RecentProfessor> recentProfessors = RecentProfessor.getRecentProfessors();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: studentAppBar(context),
      body: Column(
        children: [
          studentSearchBar(),
          Expanded(
            child: _isSearching ? searchResults() : mainContent(recentProfessors),
          ),
        ],
      )
    );
  }

  Column upcomingAppointments() {
    List<dynamic> appointments = StudentHomeAppointments.getStudentHomeAppointments();
    
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
              child: appointments.isEmpty
                ? Center(
                    child: Text(
                      'No upcoming appointments',
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.vertical,
                    separatorBuilder: (context, index) => SizedBox(height: 15),
                    padding: EdgeInsets.all(20.0),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      var appointment = appointments[index];
                      
                      // Define pastel colors for avatars
                      List<Color> pastelColors = [
                        Color(0xFFFFB3BA), // Pastel Pink
                        Color(0xFFFFDFBA), // Pastel Peach
                        Color(0xFFFFFFBA), // Pastel Yellow
                        Color(0xFFBAFFC9), // Pastel Green
                        Color(0xFFBAE1FF), // Pastel Blue
                        Color(0xFFE0BAFF), // Pastel Purple
                        Color(0xFFFFBAE3), // Pastel Magenta
                        Color(0xFFBAFFE9), // Pastel Mint
                        Color(0xFFF0E6FF), // Pastel Lavender
                        Color(0xFFE6F7FF), // Pastel Sky Blue
                      ];
                      
                      // Use appointment ID to ensure consistent color for same appointment
                      Color avatarColor = pastelColors[appointment.id.hashCode % pastelColors.length];
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: avatarColor,
                                    radius: 25,
                                    child: Text(
                                      appointment.name.split(' ').map((n) => n[0]).take(2).join(),
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Arimo',
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
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          appointment.timestamp,
                                          style: TextStyle(
                                            fontFamily: 'Arimo',
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color.fromARGB(255, 237, 194, 3),
                                      const Color.fromARGB(255, 242, 213, 86),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Handle view details button press
                                    print('View Details for appointment ID: ${appointment.id}');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    textStyle: const TextStyle(
                                      fontFamily: 'Arimo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text('View Details'),
                                ),
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
            SizedBox(
              height: 10,
            ),
            Container(
              height: 120,
              child: recentProfessors.isEmpty 
                ? Center(
                    child: Text(
                      'No recent professors',
                      style: TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (context, index) => SizedBox(width: 15),
                    padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                    itemCount: recentProfessors.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Access the professor ID here
                          String professorId = recentProfessors[index].id;
                          String professorName = recentProfessors[index].name;
                          
                          print('Tapped on professor: $professorName (ID: $professorId)');
                          
                        },
                        child: Container(
                          width: 150,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: index % 2 == 0
                                ? [Color(0xFF1A2049), Color(0xFF35408E)]
                                : [Color(0xFF35408E), Color(0xFF1A2049)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                recentProfessors[index].name,
                                style: TextStyle(
                                  fontFamily: 'Arimo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            )
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
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.search, color: Colors.grey),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Icon(Icons.filter_list, color: Colors.grey),
                  ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
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
            colors: [
              const Color(0xFF35408E),
              const Color(0xFF1A2049),
            ],
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
              backgroundColor: Colors.transparent, // Make sure the background is transparent
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
                icon: const Icon(Icons.home, color: Color(0xFFFFD418),
                ),
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
                  if (ModalRoute.of(context)?.settings.name == '/studentInbox') {
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
        Expanded(
          child: upcomingAppointments(),
        ),
      ],
    );
  }

  Widget searchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
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
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFF35408E),
                      radius: 25,
                      child: Text(
                        professor.name.split(' ').map((n) => n[0]).take(2).join(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Arimo',
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            professor.department,
                            style: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF35408E),
                        Color(0xFF1A2049),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      print('Setting an appointment with professor id: ${professor.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Set An Appointment'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
