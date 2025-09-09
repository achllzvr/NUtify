import 'package:flutter/material.dart';
import 'package:nutify/pages/login.dart';
import 'package:nutify/pages/studentHome.dart';
import 'package:nutify/pages/teacherHome.dart';
import 'package:nutify/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Service
  try {
    await FirebaseService().initialize();
  // Attach a global navigator key so we can show in-app popups from anywhere
  // (This is set again inside MyApp build; setting early is harmless.)
  FirebaseService().attachNavigatorKey(_MyAppNav.navKey);
    
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

  runApp(const AppHost());
}

class AppHost extends StatefulWidget {
  const AppHost({super.key});

  @override
  State<AppHost> createState() => _AppHostState();
}

class _AppHostState extends State<AppHost> {
  late final FirebaseService _svc;
  @override
  void initState() {
    super.initState();
    _svc = FirebaseService();
    // Listen for in-app notification stream and present popup with a stable context
    _svc.inAppNotifications.listen((notice) {
      final ctx = _MyAppNav.navKey.currentContext;
      if (ctx == null) return;

      final isFrontDesk = notice.body.trim() == 'You are being called to the front desk.';

      // Present the popup bottom sheet reliably from the UI layer
      showModalBottomSheet(
        context: ctx,
        useRootNavigator: true,
        isScrollControlled: false,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
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
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF35408E), Color(0xFF1A2049)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.notifications, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          notice.title.isNotEmpty ? notice.title : 'Notification',
                          style: const TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (notice.body.isNotEmpty)
                    Text(
                      notice.body,
                      style: const TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (!isFrontDesk)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF35408E), Color(0xFF1A2049)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF35408E).withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(ctx, rootNavigator: true).pop();
                                  await _svc.navigateForNotification(
                                    ctx,
                                    notice.title,
                                    notice.body,
                                    notice.data,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Open',
                                  style: TextStyle(
                                    fontFamily: 'Arimo',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!isFrontDesk) const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isFrontDesk ? 'Okay' : 'Dismiss',
                                style: const TextStyle(
                                  fontFamily: 'Arimo',
                                  fontWeight: FontWeight.w600,
                                ),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arimo'),
      navigatorKey: _MyAppNav.navKey,
      home: SplashScreen(),
    );
  }
}

// Holder for a single global navigator key
class _MyAppNav {
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
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
