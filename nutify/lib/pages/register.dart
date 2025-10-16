import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _selectedAccountType = 'Student';
  String? _selectedDepartment;
  
  final List<String> _departments = [
    'SACE',
    'SAHS',
    'SABM',
    'SHS',
  ];

  List<String> _departmentsForType() {
    final base = List<String>.from(_departments);
    if (_selectedAccountType == 'Faculty') {
      base.add('Others (Can be changed later at verification)');
    }
    return base;
  }

  // Email validation state
  bool _isCheckingEmail = false;
  bool _emailExists = false;
  String _emailValidationMessage = '';
  Timer? _emailCheckTimer;

  // Form validation state
  bool get _isFormValid {
    return _firstNameController.text.trim().isNotEmpty &&
           _lastNameController.text.trim().isNotEmpty &&
           _emailController.text.trim().isNotEmpty &&
           _isValidEmailFormat &&
           !_emailExists &&
           !_isCheckingEmail &&
           _passwordController.text.trim().isNotEmpty &&
           _confirmPasswordController.text.trim().isNotEmpty &&
           _selectedDepartment != null &&
           _passwordsMatch;
  }

  bool get _passwordsMatch {
    return _passwordController.text == _confirmPasswordController.text;
  }

  bool get _isValidEmailFormat {
    String email = _emailController.text.trim();
    if (email.isEmpty) return false;
    if (_selectedAccountType == 'Faculty') {
      return email.endsWith('@faculty.nu-lipa.edu.ph') &&
          RegExp(r'^[\w\.-]+@faculty\.nu-lipa\.edu\.ph$').hasMatch(email);
    }
    // Default to Student rule
    return email.endsWith('@students.nu-lipa.edu.ph') &&
        RegExp(r'^[\w\.-]+@students\.nu-lipa\.edu\.ph$').hasMatch(email);
  }

  // Password strength calculation
  Map<String, dynamic> get _passwordStrength {
    String password = _passwordController.text;
    int score = 0;
    String level = 'Very Weak';
    Color color = Colors.red;
    List<String> suggestions = [];

    if (password.isEmpty) {
      return {
        'score': 0,
        'level': 'Enter password',
        'color': Colors.grey,
        'suggestions': []
      };
    }

    // Length check
    if (password.length >= 8) {
      score += 1;
    } else {
      suggestions.add('Use at least 6 characters');
    }

    if (password.length >= 12) {
      score += 1;
    }

    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) {
      score += 1;
    } else {
      suggestions.add('Add lowercase letters');
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      score += 1;
    } else {
      suggestions.add('Add uppercase letters');
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      score += 1;
    } else {
      suggestions.add('Add numbers');
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score += 1;
    } else {
      suggestions.add('Add special characters (!@#%^&*)');
    }

    // Avoid common patterns
    if (!RegExp(r'(.)\1{2,}').hasMatch(password)) { // No repeated characters
      score += 1;
    } else {
      suggestions.add('Avoid repeated characters');
    }

    if (!RegExp(r'(123|abc|qwe|password|admin)', caseSensitive: false).hasMatch(password)) {
      score += 1;
    } else {
      suggestions.add('Avoid common patterns');
    }

    // Determine level and color based on score
    if (score <= 2) {
      level = 'Very Weak';
      color = Colors.red;
    } else if (score <= 4) {
      level = 'Weak';
      color = Colors.orange;
    } else if (score <= 6) {
      level = 'Fair';
      color = Colors.amber;
    } else if (score <= 7) {
      level = 'Good';
      color = Colors.lightGreen;
    } else {
      level = 'Strong';
      color = Colors.green;
    }

    return {
      'score': score,
      'level': level,
      'color': color,
      'suggestions': suggestions
    };
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to all text controllers to trigger UI updates
    _firstNameController.addListener(_updateFormState);
    _lastNameController.addListener(_updateFormState);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_updateFormState);
    _confirmPasswordController.addListener(_updateFormState);
  }

  void _onEmailChanged() {
    // Cancel any existing timer
    _emailCheckTimer?.cancel();
    
    setState(() {
      _emailValidationMessage = '';
      _emailExists = false;
      _isCheckingEmail = false;
    });

    String email = _emailController.text.trim();
    
    // Only check if email format is valid
    if (_isValidEmailFormat && email.isNotEmpty) {
      // Debounce the API call - wait 800ms after user stops typing
      _emailCheckTimer = Timer(Duration(milliseconds: 800), () {
        _checkEmailExists(email);
      });
    }
    
    // Update form state
    _updateFormState();
  }

  Future<void> _checkEmailExists(String email) async {
    setState(() {
      _isCheckingEmail = true;
      _emailValidationMessage = 'Checking email availability...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=checkEmail'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email}),
      );

      print('Email check response status: ${response.statusCode}');
      print('Email check response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          print('Parsed response data: $responseData');
          
          setState(() {
            _isCheckingEmail = false;

            // Prefer explicit availability/existence flags only.
            bool emailExists = false;
            if (responseData.containsKey('exists')) {
              emailExists = responseData['exists'] == true || responseData['exists'] == 'true';
            } else if (responseData.containsKey('found')) {
              emailExists = responseData['found'] == true || responseData['found'] == 'true';
            } else if (responseData.containsKey('available')) {
              // available=false => exists
              emailExists = responseData['available'] == false || responseData['available'] == 'false';
            } else {
              // No reliable signal provided; do not block registration.
              emailExists = false;
            }

            _emailExists = emailExists;

            if (_emailExists) {
              _emailValidationMessage = '✗ Email already registered';
            } else {
              _emailValidationMessage = '✓ Email available';
            }
          });
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
          setState(() {
            _isCheckingEmail = false;
            _emailValidationMessage = 'Error parsing server response';
          });
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        setState(() {
          _isCheckingEmail = false;
          _emailValidationMessage = 'Unable to verify email (HTTP ${response.statusCode})';
        });
      }
    } catch (e) {
      print('Network error: $e');
      setState(() {
        _isCheckingEmail = false;
        _emailValidationMessage = 'Network error - unable to verify email';
      });
    }
  }

  void _updateFormState() {
    setState(() {
      // This will trigger a rebuild to update button state
    });
  }

  @override
  void dispose() {
    _emailCheckTimer?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                    SizedBox(height: 40),
                    // NUtify Logo
                    nutifyLogo(),
                    SizedBox(height: 30),
                    // Registration Form Container
                    registrationFields(),
                    SizedBox(height: 20),
                    // Login Link
                    Center(child: alreadyHaveAccount()),
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

  Container registrationFields() {
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
              accountTypeButton('Faculty'),
            ],
          ),
          SizedBox(height: 25),
          // First Name Field
          buildTextField(
            controller: _firstNameController,
            hintText: 'First Name',
          ),
          SizedBox(height: 15),
          // Last Name Field
          buildTextField(
            controller: _lastNameController,
            hintText: 'Last Name',
          ),
          SizedBox(height: 15),
          // Email Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(
                controller: _emailController,
                hintText: _selectedAccountType == 'Faculty'
                    ? 'Email (@faculty.nu-lipa.edu.ph)'
                    : 'Email (@students.nu-lipa.edu.ph)',
                keyboardType: TextInputType.emailAddress,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 5, right: 5),
                child: Text(
                  _selectedAccountType == 'Faculty'
                      ? 'Use your NU Lipa faculty email (@faculty.nu-lipa.edu.ph)'
                      : 'Use your NU Lipa student email (@students.nu-lipa.edu.ph)',
                  style: TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              // Email validation feedback
              if (_emailController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5),
                  child: Row(
                    children: [
                      if (_isCheckingEmail)
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      SizedBox(width: _isCheckingEmail ? 8 : 0),
                      Expanded(
                        child: Text(
                          _emailValidationMessage.isNotEmpty
                              ? _emailValidationMessage
                              : !_isValidEmailFormat
                                  ? (_selectedAccountType == 'Faculty'
                                      ? '✗ Invalid email format (use @faculty.nu-lipa.edu.ph)'
                                      : '✗ Invalid email format (use @students.nu-lipa.edu.ph)')
                                  : '',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 12,
                            color: _emailValidationMessage.startsWith('✓')
                                ? Colors.green
                                : _emailValidationMessage.startsWith('✗') || !_isValidEmailFormat
                                    ? Colors.red
                                    : Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 15),
          // Password Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              // Password strength indicator
              if (_passwordController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 5, right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Password Strength: ',
                            style: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _passwordStrength['level'],
                            style: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 12,
                              color: _passwordStrength['color'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      // Password strength bar
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.grey.shade300,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (_passwordStrength['score'] / 8).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: _passwordStrength['color'],
                            ),
                          ),
                        ),
                      ),
                      // Password suggestions
                      if (_passwordStrength['suggestions'].isNotEmpty && _passwordStrength['suggestions'].length <= 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _passwordStrength['suggestions'].join(' • '),
                            style: TextStyle(
                              fontFamily: 'Arimo',
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 15),
          // Confirm Password Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),
              // Password match indicator
              if (_confirmPasswordController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5),
                  child: Text(
                    _passwordsMatch ? '✓ Passwords match' : '✗ Passwords do not match',
                    style: TextStyle(
                      fontFamily: 'Arimo',
                      fontSize: 12,
                      color: _passwordsMatch ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 15),
          // Department Dropdown
          buildDepartmentDropdown(),
          SizedBox(height: 25),
          // Register Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isFormValid 
                    ? [Color(0xFFFFD418), Color(0xFFFFC107)]
                    : [Colors.grey.shade400, Colors.grey.shade500],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isFormValid ? [
                BoxShadow(
                  color: Color(0xFFFFD418).withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ] : [],
            ),
            child: ElevatedButton(
              onPressed: _isFormValid ? () {
                _handleRegistration();
              } : null,
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
                disabledBackgroundColor: Colors.transparent,
                disabledForegroundColor: Colors.white70,
              ),
              child: Text(
                'Send Registration Request',
                style: TextStyle(
                  color: _isFormValid ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
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
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
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
    );
  }

  Widget buildDepartmentDropdown() {
    return Container(
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
      child: DropdownButtonFormField<String>(
        value: _selectedDepartment,
        decoration: InputDecoration(
          hintText: 'Select your department...',
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
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey.shade600,
        ),
        dropdownColor: Colors.white,
        menuMaxHeight: 200,
        borderRadius: BorderRadius.circular(12.0),
        items: _departmentsForType().map((String department) {
          return DropdownMenuItem<String>(
            value: department,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                department,
                style: TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 16,
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedDepartment = newValue;
          });
        },
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
        // Re-run email validation rules and any pending checks when type changes
        _onEmailChanged();
        // Ensure selected department remains valid for the new type
        final allowed = _departmentsForType();
        if (_selectedDepartment != null && !allowed.contains(_selectedDepartment)) {
          setState(() { _selectedDepartment = null; });
        }
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

  GestureDetector alreadyHaveAccount() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Text(
        "Already have an account? Login",
        style: TextStyle(
          fontFamily: 'Arimo',
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _handleRegistration() {
    // This should only be called when form is valid, but double-check
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete all fields correctly',
            style: TextStyle(fontFamily: 'Arimo'),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Call the registration API
    _registerUser();
  }

  Future<void> _registerUser() async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Final check for email duplicates (should already be validated)
    if (_emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This email is already registered',
            style: TextStyle(fontFamily: 'Arimo'),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF35408E)),
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  'Submitting registration...',
                  style: TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait while we process your request',
                  style: TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final response = await http.post(
        Uri.parse('https://nutify.site/api.php?action=register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'account_type': _selectedAccountType, // 'Student' or 'Faculty'
          'department': _selectedDepartment,
        }),
      );

      // Close loading dialog
      Navigator.of(context).pop();

      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> responseData = json.decode(response.body);
          
          if (responseData['success'] == true) {
            // Registration successful - show success dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Registration Successful!',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Please proceed to the faculty front desk and ask for account verification and approval to be able to use your account.',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 25),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF35408E), Color(0xFF1A2049)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close success dialog
                              Navigator.pop(context); // Go back to login page
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                fontFamily: 'Arimo',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text('Return to Login'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

            // Clear the form
            _firstNameController.clear();
            _lastNameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();
            setState(() {
              _selectedDepartment = null;
              _emailValidationMessage = '';
              _emailExists = false;
            });

          } else {
            // Registration failed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  responseData['message'] ?? 'Registration failed',
                  style: TextStyle(fontFamily: 'Arimo'),
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
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
      } else {
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
    } catch (e) {
      // Close loading dialog if still open
      try {
        Navigator.of(context).pop();
      } catch (e) {}
      
      print('Network error: $e');
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
