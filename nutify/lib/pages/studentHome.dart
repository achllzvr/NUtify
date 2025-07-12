import 'package:flutter/material.dart';
import 'package:nutify/models/recentProfessorsModel.dart';

class StudentHome extends StatelessWidget {
  StudentHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the recent professors data
    List<RecentProfessor> recentProfessors = RecentProfessor.getRecentProfessors();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: studentAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          studentSearchBar(),
          mostRecentProfessors(recentProfessors)
        ],
      )
    );

  }

  Column mostRecentProfessors(List<RecentProfessor> recentProfessors) {
    return Column(
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
              height: 150,
              child: ListView.separated(
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
                        color: index % 2 == 0 ? Color.fromARGB(228, 26, 32, 73) : Color.fromARGB(226, 53, 63, 142),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
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
              suffixIcon: Container(
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

  AppBar studentAppBar() {
    return AppBar(
      title: const Text(
        'Student Home',

        style: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
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
            margin: const EdgeInsets.all(10.0),
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
                  // Handle home button tap
                },
              ),
              IconButton(
                icon: const Icon(Icons.inbox, color: Color(0xFFFFD418)),
                onPressed: () {
                  // Handle inbox button tap
                },
              ),
            ],
          ),
        ),
      ),

    );
  }


}