import 'package:flutter/material.dart';
import 'package:nutify/pages/login.dart';
import 'package:nutify/pages/studentHome.dart';
import 'package:nutify/pages/teacherHome.dart';
import 'package:nutify/pages/moderatorHome.dart';
import 'package:nutify/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Service
  try {
    await FirebaseService().initialize();
    
    // Try to get FCM token with retry logic after initialization
    Future.delayed(Duration(seconds: 3), () async {
      print('Attempting to get FCM token...');
      
      // Get FCM token for all platforms (iOS, Android, etc.)
      String? token = await FirebaseService().getFCMTokenWithRetry();
      if (token != null) {
        print('FCM token successfully obtained: $token');
      } else {
        print('Failed to obtain FCM token');
        
        // Try getting status for debugging
        Map<String, dynamic> status = await FirebaseService().getFCMStatus();
        print('FCM Status: $status');
      }
    });
  } catch (e) {
    // Firebase initialization failed, but app can still run
    print('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arimo'),
      home: SplashScreen(),
    );
  }
}

// Splash Screen to check login state and navigate accordingly
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginState();
  }

  Future<void> checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String userType = prefs.getString('userType') ?? '';
    
    print('Checking login state...');
    print('isLoggedIn: $isLoggedIn');
    print('userType: $userType');
    
    await Future.delayed(Duration(seconds: 2)); // Optional splash delay
    
    if (isLoggedIn) {
      String userType = prefs.getString('userType') ?? '';
      
      // Navigate to appropriate home screen based on user type
      if (userType == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentHome(),
            settings: RouteSettings(name: '/studentHome'),
          ),
        );
      } else if (userType == 'teacher') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TeacherHome(),
            settings: RouteSettings(name: '/teacherHome'),
          ),
        );
      } else if (userType == 'moderator') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ModeratorHome(),
            settings: RouteSettings(name: '/moderatorHome'),
          ),
        );
      } else {
        // Unknown user type, go to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } else {
      // Not logged in, go to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF35408E), const Color(0xFF1A2049)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/NUtify_full_logo.png',
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'NUtify',
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
