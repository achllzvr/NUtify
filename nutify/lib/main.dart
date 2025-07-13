import 'package:flutter/material.dart';
import 'package:nutify/pages/login.dart';
import 'package:nutify/services/firebase_service.dart';

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
      home: LoginPage(),
    );
  }
}
