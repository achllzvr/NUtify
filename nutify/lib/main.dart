import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nutify/services/ongoing_service.dart';
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
      builder: (context, child) {
        // Start ongoing appointment polling once app is built
        OngoingService().start();
        return Stack(
          children: [
            if (child != null) child,
            // Global ongoing meeting bar overlay
            Positioned(
              left: 12,
              right: 12,
              bottom: 18,
              child: ValueListenableBuilder<OngoingAppointment?>(
                valueListenable: OngoingService().current,
                builder: (context, og, _) {
                  if (og == null) return const SizedBox.shrink();
                  return _OngoingBanner(ongoing: og);
                },
              ),
            ),
          ],
        );
      },
      home: SplashScreen(),
    );
  }
}

// Holder for a single global navigator key
class _MyAppNav {
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
}

class _OngoingBanner extends StatefulWidget {
  final OngoingAppointment ongoing;
  const _OngoingBanner({required this.ongoing});

  @override
  State<_OngoingBanner> createState() => _OngoingBannerState();
}

class _OngoingBannerState extends State<_OngoingBanner> {
  bool _expanded = false;

  String _inferCounterpartName() {
    // Show the counterpart name only (student for teacher, teacher for student)
    final prefs = SharedPreferences.getInstance();
    // But for pill, just use the logic as before
    if ((widget.ongoing.teacherName).trim().isNotEmpty && (widget.ongoing.studentName).trim().isNotEmpty) {
      return widget.ongoing.teacherName;
    }
    if (widget.ongoing.teacherName.trim().isNotEmpty) return widget.ongoing.teacherName;
    if (widget.ongoing.studentName.trim().isNotEmpty) return widget.ongoing.studentName;
    return '';
  }

  Future<void> _showStatusConfirmationDialog(BuildContext context, String status, int appointmentId, int facultyId, Future<void> Function() onConfirm) async {
    final navContext = _MyAppNav.navKey.currentContext ?? context;
    return showDialog<void>(
      context: navContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 3,
                  blurRadius: 20,
                  offset: Offset(0, 8),
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
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4CAF50).withOpacity(0.1), Color(0xFF4CAF50).withOpacity(0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(Icons.task_alt_outlined, color: Color(0xFF4CAF50), size: 30),
                ),
                SizedBox(height: 20),
                Text('Confirm Action', style: TextStyle(fontFamily: 'Arimo', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                SizedBox(height: 10),
                Text('Are you sure you want to mark this meeting as completed?', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Arimo', fontSize: 16, color: Colors.grey.shade600, height: 1.4)),
                SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade300], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 6, offset: Offset(0, 3))],
                        ),
                        child: ElevatedButton(
                          onPressed: () { Navigator.of(context).pop(); },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.grey.shade700,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            textStyle: TextStyle(fontFamily: 'Arimo', fontSize: 16, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text('Cancel'),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Color(0xFF4CAF50).withOpacity(0.4), spreadRadius: 1, blurRadius: 8, offset: Offset(0, 4))],
                        ),
                        child: ElevatedButton(
                          onPressed: () async { Navigator.of(context).pop(); await onConfirm(); },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            textStyle: TextStyle(fontFamily: 'Arimo', fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text('Continue'),
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
  }

  Future<Map<String, dynamic>> _updateAppointmentStatus(int appointmentId, String status, int facultyId) async {
    String action = status == 'completed' ? 'updateAppStatusC' : 'updateAppStatusM';
    final response = await http.post(
      Uri.parse('https://nutify.site/api.php?action=$action'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'appointment_id': appointmentId,
        'faculty_id': facultyId,
        'status': status,
      }),
    );
    return jsonDecode(response.body);
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(_expanded ? 24 : 28);
    final gradient = _expanded
        ? const LinearGradient(
            colors: [Colors.white, Color(0xFFF8F9FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFE57373)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          );
    final boxShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(_expanded ? 0.10 : 0.18),
        blurRadius: _expanded ? 8 : 12,
        offset: const Offset(0, 6),
      ),
    ];
    // Only show completed button for teacher ongoing pill
    final userTypeFuture = SharedPreferences.getInstance();
    return FutureBuilder<SharedPreferences>(
      future: userTypeFuture,
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final userType = prefs?.getString('userType') ?? '';
        final userId = prefs?.getString('userId') ?? '';
        return Material(
          color: Colors.transparent,
          elevation: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: _expanded ? 24 : 4),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: gradient,
              boxShadow: boxShadow,
            ),
            child: InkWell(
              borderRadius: borderRadius,
              onTap: _toggleExpanded,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                child: _expanded
                    ? Column(
                        key: const ValueKey('expanded'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: _OngoingDetails(ongoing: widget.ongoing, isBanner: true),
                          ),
                          if (userType == 'teacher')
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                margin: const EdgeInsets.only(top: 8, right: 8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF4CAF50).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showStatusConfirmationDialog(
                                      context,
                                      'completed',
                                      widget.ongoing.id,
                                      int.tryParse(userId) ?? 0,
                                      () async {
                                        final result = await _updateAppointmentStatus(widget.ongoing.id, 'completed', int.tryParse(userId) ?? 0);
                                        if (result['error'] == false) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Meeting marked as completed!', style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
                                              backgroundColor: Color(0xFF35408E),
                                            ),
                                          );
                                          // Refresh ongoing pill
                                          await OngoingService().refresh();
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(result['message'] ?? 'Failed to update meeting', style: TextStyle(fontFamily: 'Arimo', color: Colors.white)),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontFamily: 'Arimo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('compact'),
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              _inferCounterpartName(),
                              style: const TextStyle(
                                fontFamily: 'Arimo',
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.video_call, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Ongoing Meeting',
                                    style: TextStyle(
                                      fontFamily: 'Arimo',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OngoingDetails extends StatelessWidget {
  final OngoingAppointment ongoing;
  final bool isBanner;
  const _OngoingDetails({required this.ongoing, this.isBanner = false});

  @override
  Widget build(BuildContext context) {
    final details = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isBanner)
            Center(
              child: Container(
                width: 42, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.meeting_room, color: Color(0xFF35408E)),
              SizedBox(width: 8),
              Text('Ongoing Meeting', style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          _kv('Professor', ongoing.teacherName),
          _kv('Student', ongoing.studentName),
          _kv('Date', ongoing.scheduleDate),
          _kv('Time', ongoing.scheduleTime),
          if (ongoing.reason.isNotEmpty) _kv('Reason', ongoing.reason),
          if (ongoing.remarks.isNotEmpty) _kv('Remarks', ongoing.remarks),
          const SizedBox(height: 16),
          if (!isBanner)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
        ],
      ),
    );
    if (isBanner) {
      return details;
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: details,
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(k, style: TextStyle(fontFamily: 'Arimo', fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(v, style: const TextStyle(fontFamily: 'Arimo', fontSize: 14, color: Color(0xFF2C3E50))),
          ),
        ],
      ),
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
