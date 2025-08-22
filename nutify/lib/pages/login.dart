import 'package:flutter/material.dart';
import 'package:nutify/pages/studentHome.dart';
import 'package:nutify/pages/teacherHome.dart';
import 'package:nutify/pages/register.dart';
import 'package:nutify/services/firebase_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedAccountType = 'Student';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
                    // NUtify Logo
                    nutifyLogo(),
                    SizedBox(height: 40),
                    // Login Form Container
                    loginFields(),
                    SizedBox(height: 30),
                    // Forgot Password Link
                    Center(child: loginForgotPassword()),
                    SizedBox(height: 15),
                    // Register Link
                    Center(child: loginRegister()),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getDeviceToken() async {
    String url = "https://nutify.site/api.php?action=fetchToken";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userId') ?? '';

    try {
      final Map<String, dynamic> requestBody = {'userID': userID};

      // Make HTTP POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData['error'] == false) {
            // Successfully retrieved FCM token
            List<dynamic> tokens = responseData['fcm_token'];
            if (tokens.isNotEmpty) {
              // Token available for use in push notifications
            }
          }
        } catch (jsonError) {
          // Handle JSON parsing error silently
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void loginUser() async {
    String url =
        "https://nutify.site/api.php?action=login"; // Action as query parameter
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // Get FCM token before login
      String? fcmToken = await FirebaseService().getToken();

      // Create request body that matches your API expectations
      final Map<String, dynamic> requestBody = {
        'username': username, // API expects full name like "John Doe"
        'password': password,
        'account_type': _selectedAccountType.toLowerCase(), // Include selected account type
        'fcm_token': fcmToken ?? '', // Include FCM token in login request
      };
      
      // Debug print for request data
      print('Login Request URL: $url');
      print('Login Request Body: $requestBody');
      print('FCM Token: $fcmToken');
      
      // Make HTTP POST request with JSON body
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // Debug prints for response details
      print('Login Response Status Code: ${response.statusCode}');
      print('Login Response Body: ${response.body}');
      print('Login Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        try {
          // Parse JSON response
          final Map<String, dynamic> responseData = json.decode(response.body);
          print('Parsed Response Data: $responseData');

          if (responseData['success'] == true) {
            // Login successful
            String userId = responseData['user_id'].toString();
            String userType = responseData['user_type'].toString().toLowerCase();
            String userFn = responseData['user_fn'].toString();
            String userLn = responseData['user_ln'].toString();

            // Save login state to SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('userId', userId);
            await prefs.setString('userType', userType);
            await prefs.setString('userFn', userFn);
            await prefs.setString('userLn', userLn);

            // Send FCM token to server for this specific user
            if (fcmToken != null && fcmToken.isNotEmpty) {
              await FirebaseService().sendTokenToServerForUser(
                userId,
                fcmToken,
              );
            }

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Welcome, ${responseData['user_fn']} ${responseData['user_ln']}!',
                    style: TextStyle(fontFamily: 'Arimo'),
                  ),
                  backgroundColor: Color(0xFF4CAF50),
                  duration: Duration(seconds: 2),
                ),
              );

              // Navigate based on user type (student, teacher)
              if (userType == 'student') {
                // Student
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentHome(),
                    settings: RouteSettings(name: '/studentHome'),
                  ),
                  (Route<dynamic> route) => false,
                );
              } else if (userType == 'teacher') {
                // Teacher
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherHome(),
                    settings: RouteSettings(name: '/teacherHome'),
                  ),
                  (Route<dynamic> route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Unknown user type: $userType',
                      style: TextStyle(fontFamily: 'Arimo'),
                    ),
                    backgroundColor: Color(0xFF35408E),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          } else {
            // Login failed
            String errorMessage = responseData['message'] ?? 'Invalid credentials';
            String errorType = responseData['error_type'] ?? '';
            
            // Debug prints for login failure
            print('Login Failed - Error Message: $errorMessage');
            print('Login Failed - Error Type: $errorType');
            print('Login Failed - Full Response: $responseData');
            
            if (mounted) {
              Color snackBarColor;
              
              // Use different colors for different error types
              if (errorType == 'account_type_mismatch') {
                snackBarColor = Colors.orange;
              } else {
                snackBarColor = Colors.red;
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    errorMessage,
                    style: TextStyle(fontFamily: 'Arimo'),
                  ),
                  backgroundColor: snackBarColor,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          }
        } catch (jsonError) {
          print('JSON Parsing Error: $jsonError');
          print('Raw Response Body: ${response.body}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Invalid server response. Please try again.',
                  style: TextStyle(fontFamily: 'Arimo'),
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        // HTTP error
        print('HTTP Error - Status Code: ${response.statusCode}');
        print('HTTP Error - Response Body: ${response.body}');
        print('HTTP Error - Response Headers: ${response.headers}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Server error (${response.statusCode}). Please try again later.',
                style: TextStyle(fontFamily: 'Arimo'),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Network or other error
      print('Network/Other Error: $e');
      print('Error Type: ${e.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Network error. Please check your connection and try again.',
              style: TextStyle(fontFamily: 'Arimo'),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Container nutifyLogo() {
    return Container(
      height: 80,
      child: Image.asset(
        'assets/icons/NUtify_full_logo.png',
        fit: BoxFit.contain,
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
    );
  }

  Container loginFields() {
    return Container(
      padding: EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Type Selection Title
          Center(
            child: Text(
              'Select Account Type:',
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          SizedBox(height: 15),
          // Account Type Selection Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              accountTypeButton('Student'),
              accountTypeButton('Teacher'),
            ],
          ),
          SizedBox(height: 30),
          // Username Field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
              boxShadow: [
                // Simulate inset shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: -1,
                  blurRadius: 3,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Enter your ID number',
                hintStyle: TextStyle(
                  fontFamily: 'Arimo',
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 16,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          SizedBox(height: 15),
          // Password Field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
              boxShadow: [
                // Simulate inset shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: -1,
                  blurRadius: 3,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(
                  fontFamily: 'Arimo',
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 16,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          SizedBox(height: 25),
          // Login Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD418), Color(0xFFFFC107)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFFD418).withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                _handleLogin();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector loginRegister() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterPage()),
        );
      },
      child: Text(
        "Don't have an account? Register",
        style: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  GestureDetector loginForgotPassword() {
    return GestureDetector(
      onTap: () {
        // Handle forgot password when implemented
      },
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget accountTypeButton(String type) {
    bool isSelected = _selectedAccountType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAccountType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [const Color(0xFF35408E), const Color(0xFF1A2049)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  // Sunken effect for selected state
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: -1,
                    blurRadius: 6,
                    offset: Offset(2, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    spreadRadius: -1,
                    blurRadius: 6,
                    offset: Offset(-2, -2),
                  ),
                ]
              : [
                  // Sunken effect for unselected state
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: -1,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    spreadRadius: -1,
                    blurRadius: 4,
                    offset: Offset(-1, -1),
                  ),
                ],
        ),
        child: Text(
          type,
          style: TextStyle(
            fontFamily: 'Arimo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter both username and password',
            style: TextStyle(fontFamily: 'Arimo'),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Call the API login function
    loginUser();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data
    
    // Navigate back to login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // Static method for logout from other pages
  static Future<void> logoutFromApp(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data
    
    // Navigate back to login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
