import 'package:flutter/material.dart';
import 'package:nutify/pages/studentHome.dart';

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
            colors: [
              const Color(0xFF35408E),
              const Color(0xFF1A2049),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
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
                Center(
                  child: loginForgotPassword(),
                ),
                SizedBox(height: 15),
                // Register Link
                Center(
                  child: loginRegister(),
                ),
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
                    colors: [
                      Colors.white,
                      Color(0xFFF8F9FA),
                    ],
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
                        accountTypeButton('Faculty'),
                        accountTypeButton('Moderator'),
                      ],
                    ),
                    SizedBox(height: 30),
                    // Username Field
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.grey.shade100,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
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
                          hintText: 'Username',
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
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
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
                          colors: [
                            Color(0xFFFFD418),
                            Color(0xFFFFC107),
                          ],
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
                    print('Register tapped');
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
                    print('Forgot Password tapped');
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
        print('Selected account type: $type');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(
            colors: [
              const Color(0xFF35408E),
              const Color(0xFF1A2049),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : LinearGradient(
            colors: [
              Colors.grey.shade300,
              Colors.grey.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected ? [
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
          ] : [
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

    print('Login attempt:');
    print('Account Type: $_selectedAccountType');
    print('Username: $username');
    print('Password: $password');

    // For now, simulate successful login and navigate to appropriate page
    if (_selectedAccountType == 'Student') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => StudentHome(),
          settings: RouteSettings(name: '/studentHome'),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      // Show message for other account types (not implemented yet)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$_selectedAccountType login not implemented yet',
            style: TextStyle(fontFamily: 'Arimo'),
          ),
          backgroundColor: Color(0xFF35408E),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
