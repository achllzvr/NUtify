import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import '../firebase_options.dart';
import 'package:nutify/pages/studentHome.dart';
import 'package:nutify/pages/teacherHome.dart';
import 'package:nutify/pages/studentInbox.dart';
import 'package:nutify/pages/teacherInbox.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseMessaging? _messaging;
  bool _tokenAcquisitionInProgress = false;
  GlobalKey<NavigatorState>? _navKey;
  bool _popupShowing = false;
  RemoteMessage? _queuedMessage;

  // Stream to broadcast in-app notification events to the UI layer
  final StreamController<InAppNotice> _inAppStreamController =
      StreamController<InAppNotice>.broadcast();
  Stream<InAppNotice> get inAppNotifications => _inAppStreamController.stream;

  // Initialize Firebase and FCM
  Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Firebase Messaging
      _messaging = FirebaseMessaging.instance;

      // Request notification permissions (especially important for iOS)
      await requestNotificationPermissions();

      // Ensure iOS shows alerts in foreground (optional; we'll also show custom in-app popup)
      await _messaging!.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Configure FCM
      await configureFCM();

      print('Firebase Service initialized successfully');
    } catch (e) {
      print('Error initializing Firebase Service: $e');
    }
  }

  // Request notification permissions
  Future<void> requestNotificationPermissions() async {
    if (_messaging == null) return;

    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional notification permissions');
    } else {
      print('User declined or has not accepted notification permissions');
    }
  }

  // Configure FCM messaging
  Future<void> configureFCM() async {
    if (_messaging == null) return;

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message notification: ${message.notification!.body}');
      }
      _showNotification(message); // print diagnostics

      // Resolve title/body for popup and emit through the stream
      final title = message.notification?.title?.trim();
      final body = message.notification?.body?.trim();
      final resolvedTitle = (title?.isNotEmpty == true)
          ? title!
          : (message.data['title']?.toString() ?? '');
      final resolvedBody = (body?.isNotEmpty == true)
          ? body!
          : (message.data['body']?.toString() ?? '');
      if (resolvedTitle.isNotEmpty || resolvedBody.isNotEmpty) {
        _inAppStreamController.add(
          InAppNotice(title: resolvedTitle, body: resolvedBody, data: message.data),
        );
      }
    });

    // Handle when user taps on notification and app is opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');

      // Navigate based on status/type to Home for accepted, Inbox otherwise
      final ctx = _navKey?.currentContext;
      if (ctx != null) {
        final title = message.notification?.title?.trim();
        final body = message.notification?.body?.trim();
        final resolvedTitle = (title?.isNotEmpty == true)
            ? title!
            : (message.data['title']?.toString() ?? '');
        final resolvedBody = (body?.isNotEmpty == true)
            ? body!
            : (message.data['body']?.toString() ?? '');
        navigateForNotification(ctx, resolvedTitle, resolvedBody, message.data);
      } else {
        print('No context available in onMessageOpenedApp');
      }
    });

    // Handle cold-start (terminated) notification tap
    try {
      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        print('App opened from terminated by notification');
        final ctx = _navKey?.currentContext;
        if (ctx != null) {
          final title = initialMessage.notification?.title?.trim();
          final body = initialMessage.notification?.body?.trim();
          final resolvedTitle = (title?.isNotEmpty == true)
              ? title!
              : (initialMessage.data['title']?.toString() ?? '');
          final resolvedBody = (body?.isNotEmpty == true)
              ? body!
              : (initialMessage.data['body']?.toString() ?? '');
          // Use microtask to ensure Navigator is ready post-runApp
          Future.microtask(() => navigateForNotification(ctx, resolvedTitle, resolvedBody, initialMessage.data));
        } else {
          print('No context available for initialMessage');
        }
      }
    } catch (e) {
      print('Error handling initialMessage: $e');
    }

    // Listen for token refresh
    _messaging!.onTokenRefresh.listen((String token) {
      print('FCM Token refreshed: $token');
      _sendTokenToServer(token);
      _saveTokenLocally(token);
    });

    // For token acquisition, rely on main.dart logic to avoid conflicts
    print('iOS detected - checking if running on simulator or device');
  }

  // Get current FCM token with retry logic for iOS APNS token
  Future<String?> getToken() async {
    if (_messaging == null) return null;

    try {
      // On iOS, we need to ensure APNS token is available first
      if (Platform.isIOS) {
        // Try to get APNS token first
        String? apnsToken = await _messaging!.getAPNSToken();
        if (apnsToken == null) {
          print('APNS token not available yet, waiting...');
          // Wait for APNS token with retry logic
          for (int i = 0; i < 10; i++) {
            await Future.delayed(Duration(milliseconds: 500));
            apnsToken = await _messaging!.getAPNSToken();
            if (apnsToken != null) {
              print('APNS token acquired: $apnsToken');
              break;
            }
          }
          
          if (apnsToken == null) {
            print('APNS token still not available after waiting');
            return null;
          }
        }
      }

      String? token = await _messaging!.getToken();
      print('FCM Token: $token');

      if (token != null) {
        // Save token locally
        await _saveTokenLocally(token);
      }

      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Get FCM token with retry mechanism specifically for post-initialization
  Future<String?> getFCMTokenWithRetry({int maxRetries = 5, int delaySeconds = 2}) async {
    if (_messaging == null) return null;
    
    if (_tokenAcquisitionInProgress) {
      print('Token acquisition already in progress, skipping...');
      return null;
    }
    
    _tokenAcquisitionInProgress = true;
    
    try {
      for (int attempt = 0; attempt < maxRetries; attempt++) {
        try {
          // On iOS, check if APNS token is available
          if (Platform.isIOS) {
            String? apnsToken = await _messaging!.getAPNSToken();
            if (apnsToken == null) {
              print('Attempt ${attempt + 1}: APNS token not available yet, waiting...');
              
              // After a few attempts, try direct token acquisition (useful for simulators)
              if (attempt >= 2) {
                print('Attempting direct FCM token acquisition...');
                try {
                  String? directToken = await _messaging!.getToken();
                  if (directToken != null) {
                    print('Direct FCM token obtained on attempt ${attempt + 1}: $directToken');
                    await _saveTokenLocally(directToken);
                    return directToken;
                  }
                } catch (e) {
                  print('Direct token attempt failed: $e');
                }
              }
              
              if (attempt < maxRetries - 1) {
                await Future.delayed(Duration(seconds: delaySeconds));
                continue;
              } else {
                print('APNS token not available after $maxRetries attempts');
                
                // Final attempt with direct FCM token
                print('Making final attempt with direct FCM token...');
                try {
                  String? finalToken = await _messaging!.getToken();
                  if (finalToken != null) {
                    print('Final direct FCM token obtained: $finalToken');
                    await _saveTokenLocally(finalToken);
                    return finalToken;
                  }
                } catch (e) {
                  print('Final direct token attempt failed: $e');
                }
                
                return null;
              }
            } else {
              print('APNS token available: $apnsToken');
            }
          }

          String? token = await _messaging!.getToken();
          if (token != null) {
            print('FCM Token obtained successfully: $token');
            await _saveTokenLocally(token);
            return token;
          } else {
            print('Attempt ${attempt + 1}: FCM token is null');
          }
        } catch (e) {
          print('Attempt ${attempt + 1} failed to get FCM token: $e');
        }

        if (attempt < maxRetries - 1) {
          await Future.delayed(Duration(seconds: delaySeconds));
        }
      }

      print('Failed to get FCM token after $maxRetries attempts');
      return null;
    } finally {
      _tokenAcquisitionInProgress = false;
    }
  }

  // Send token to server (equivalent to the Java sendTokenToServer method)
  Future<void> _sendTokenToServer(String token) async {
    try {
      // Get user ID from shared preferences (you'll need to save this during login)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');

      if (userId == null) {
        print('No user ID found, cannot send token to server');
        return;
      }

      String url = "https://nutify.site/api.php?action=updateToken";

      final Map<String, dynamic> requestBody = {
        'userID': userId,
        'fcm_token': token,
      };

      print('Sending FCM token to server: $token');
      print('For user ID: $userId');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Token update response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['error'] == false) {
          print('FCM token successfully sent to server');
        } else {
          print('Server error: ${responseData['message']}');
        }
      }
    } catch (e) {
      print('Error sending token to server: $e');
    }
  }

  // Send token to server with specific user ID (called during login)
  Future<void> sendTokenToServerForUser(String userId, String token) async {
    try {
      String url = "https://nutify.site/api.php?action=updateToken";

      final Map<String, dynamic> requestBody = {
        'userID': userId,
        'fcm_token': token,
      };

      print('Sending FCM token to server for user: $userId');
      print('Token: $token');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Token update response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['error'] == false) {
          print('FCM token successfully sent to server');
          // Save user ID for future token updates
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userId);
        } else {
          print('Server error: ${responseData['message']}');
        }
      }
    } catch (e) {
      print('Error sending token to server: $e');
    }
  }

  // Save token locally
  Future<void> _saveTokenLocally(String token) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      print('FCM token saved locally');
    } catch (e) {
      print('Error saving FCM token locally: $e');
    }
  }

  // Get locally saved token
  Future<String?> getSavedToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      print('Error getting saved FCM token: $e');
      return null;
    }
  }

  // Check current notification permission status
  Future<AuthorizationStatus> getNotificationPermissionStatus() async {
    if (_messaging == null) return AuthorizationStatus.notDetermined;
    
    NotificationSettings settings = await _messaging!.getNotificationSettings();
    return settings.authorizationStatus;
  }

  // Get a comprehensive status of FCM setup
  Future<Map<String, dynamic>> getFCMStatus() async {
    Map<String, dynamic> status = {
      'messaging_initialized': _messaging != null,
      'permission_status': 'unknown',
      'fcm_token': null,
      'apns_token': null,
    };

    if (_messaging != null) {
      try {
        // Get permission status
        NotificationSettings settings = await _messaging!.getNotificationSettings();
        status['permission_status'] = settings.authorizationStatus.toString();

        // Try to get APNS token (iOS only)
        if (Platform.isIOS) {
          String? apnsToken = await _messaging!.getAPNSToken();
          status['apns_token'] = apnsToken;
        }

        // Try to get FCM token
        String? fcmToken = await _messaging!.getToken();
        status['fcm_token'] = fcmToken;
      } catch (e) {
        status['error'] = e.toString();
      }
    }

    return status;
  }

  // Show notification (you can customize this based on your UI needs)
  void _showNotification(RemoteMessage message) {
    // This is a simple print for now - you can implement actual notification display
    // using a package like flutter_local_notifications if needed
    print('Notification received:');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');

    // For now, we'll just print the notification
    // In a real app, you might want to show an in-app notification or update the UI
  }

  // Attach navigator key from app to present UI from service
  void attachNavigatorKey(GlobalKey<NavigatorState> key) {
    _navKey = key;
  }

  // In-app popup using bottom sheet styled like the app
  void _showInAppPopup(RemoteMessage message) {
    try {
      final ctx = _getNavigatorContext();
      if (ctx == null) {
        print('No navigator context available for in-app popup; will retry...');
        _queuedMessage = message;
        _retryShowPopup(message, attempts: 10, intervalMs: 200);
        return;
      }

      final title = message.notification?.title?.trim();
      final body = message.notification?.body?.trim();
      final resolvedTitle = (title?.isNotEmpty == true)
          ? title!
          : (message.data['title']?.toString() ?? 'Notification');
      final resolvedBody = (body?.isNotEmpty == true)
          ? body!
          : (message.data['body']?.toString() ?? '');

      if ((resolvedTitle.isEmpty) && (resolvedBody.isEmpty)) {
        // Nothing meaningful to show
        return;
      }

      if (_popupShowing) {
        // Avoid stacking multiple popups; could implement a queue if needed
        return;
      }
      _popupShowing = true;

  final bool isFrontDesk = resolvedBody.trim() == 'You are being called to the front desk.';

  WidgetsBinding.instance.addPostFrameCallback((_) {
        showModalBottomSheet(
          context: ctx,
          isScrollControlled: false,
          useRootNavigator: true,
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
                  // Handle
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
                          resolvedTitle,
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
                  if (resolvedBody.isNotEmpty)
                    Text(
                      resolvedBody,
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
                                  await navigateForNotification(ctx, resolvedTitle, resolvedBody, message.data);
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
        ).whenComplete(() {
          _popupShowing = false;
        });
      });
    } catch (e) {
      print('Error showing in-app popup: $e');
      _popupShowing = false;
    }
  }

  BuildContext? _getNavigatorContext() {
    // Try multiple ways to get a viable context
    return _navKey?.currentContext ?? _navKey?.currentState?.overlay?.context ?? _navKey?.currentState?.context;
  }

  void _retryShowPopup(RemoteMessage message, {int attempts = 10, int intervalMs = 200}) async {
    for (int i = 0; i < attempts; i++) {
      await Future.delayed(Duration(milliseconds: intervalMs));
      final ctx = _getNavigatorContext();
      if (ctx != null) {
        print('Context acquired on retry ${i + 1}; showing popup');
        _showInAppPopup(message);
        _queuedMessage = null;
        return;
      }
    }
    print('Failed to acquire context after $attempts attempts; giving up on popup');
  }

  Future<void> navigateForNotification(BuildContext ctx, String title, String body, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getString('userType') ?? '';

      bool isAccepted = false;
      final statusData = (data['status']?.toString() ?? '').toLowerCase();
      if (statusData == 'accepted') {
        isAccepted = true;
      } else {
        final t = title.toLowerCase();
        final b = body.toLowerCase();
        if (t.contains('accepted') || b.contains('accepted')) {
          isAccepted = true;
        }
      }

      Widget destination;
      if (isAccepted) {
        destination = (userType == 'teacher') ? TeacherHome() : StudentHome();
      } else {
        destination = (userType == 'teacher') ? TeacherInbox() : StudentInbox();
      }

  Navigator.of(ctx).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } catch (e) {
      print('Error handling Open action: $e');
      // Fallback: simple snackbar
      try {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Unable to open page for notification')),
        );
      } catch (_) {}
    }
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('User tapped notification');
    print('Message data: ${message.data}');

    // Here you can navigate to specific screens based on the notification data
    // For example, if the notification contains a 'screen' parameter:
    // String? targetScreen = message.data['screen'];
    // if (targetScreen != null) {
    //   // Navigate to the target screen
    // }
  }

  // Delete token (for logout)
  Future<void> deleteToken() async {
    try {
      if (_messaging != null) {
        await _messaging!.deleteToken();

        // Remove locally saved token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('fcm_token');
        await prefs.remove('user_id');

        print('FCM token deleted');
      }
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    print('Background message notification: ${message.notification!.body}');
  }
}

class InAppNotice {
  final String title;
  final String body;
  final Map<String, dynamic> data;
  InAppNotice({required this.title, required this.body, required this.data});
}
