import 'package:flutter/material.dart';
import 'package:nutify/pages/login.dart';
import 'package:nutify/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Service
  try {
    await FirebaseService().initialize();
  } catch (e) {
    // Firebase initialization failed, but app can still run
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
