import 'package:flutter/material.dart';
import 'package:nutify/pages/studentHome.dart';

class StudentInbox extends StatefulWidget {
  StudentInbox({super.key});

  @override
  _StudentInboxState createState() => _StudentInboxState();
}

class _StudentInboxState extends State<StudentInbox> with SingleTickerProviderStateMixin {
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
          Container(
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
                Tab(text: 'Cancelled'),
                Tab(text: 'Missed'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending Tab
                Center(
                  child: Text(
                    'Pending Appointments',
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                // Cancelled Tab
                Center(
                  child: Text(
                    'Cancelled Appointments',
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                // Missed Tab
                Center(
                  child: Text(
                    'Missed Appointments',
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                // Completed Tab
                Center(
                  child: Text(
                    'Completed Appointments',
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
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
            // Handle profile icon tap
          },
          child: Container(
            margin: const EdgeInsets.only(right: 25.0),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/icons/student.png'),
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
                  if (ModalRoute.of(context)?.settings.name == '/studentInbox' || 
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