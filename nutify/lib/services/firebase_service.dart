import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseMessaging? _messaging;
  bool _tokenAcquisitionInProgress = false;

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
        _showNotification(message);
      }
    });

    // Handle when user taps on notification and app is opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');

      // Handle navigation based on notification data
      _handleNotificationTap(message);
    });

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

  // Check if running on iOS simulator
  Future<bool> isSimulator() async {
    if (!Platform.isIOS) return false;
    
    try {
      // Use Platform.environment to check for simulator indicators
      // Simulators typically have specific environment variables
      final Map<String, String> env = Platform.environment;
      
      // Check for simulator-specific environment variables
      if (env.containsKey('SIMULATOR_DEVICE_NAME') || 
          env.containsKey('SIMULATOR_ROOT') ||
          env.containsKey('IPHONE_SIMULATOR_ROOT')) {
        return true;
      }
      
      // Another approach: check if we're running in a sandbox that's typical of simulators
      try {
        final Directory documentsDir = Directory('/var/mobile/');
        final bool canAccess = await documentsDir.exists();
        // Real devices typically can't access this path, simulators might
        
        // More reliable: check the device's file system structure
        // Simulators have different paths than real devices
        final Directory simPath = Directory('/Users/');
        final bool hasSimPath = await simPath.exists();
        
        if (hasSimPath) {
          return true; // Simulators run on macOS and have /Users/ directory
        }
      } catch (e) {
        // Can't determine from file system
      }
      
      // Final fallback: be conservative and assume real device
      // It's better to try real FCM on a real device than to use mock tokens
      return false;
    } catch (e) {
      print('Error detecting simulator: $e');
      return false; // Default to real device if detection fails
    }
  }

  // Get FCM token for simulator (bypasses APNS requirement)
  Future<String?> getSimulatorToken() async {
    if (_messaging == null) return null;
    
    try {
      print('Attempting to get FCM token for simulator...');
      
      // For iOS simulators, Firebase doesn't support real FCM tokens
      // Return a mock token for development purposes
      if (Platform.isIOS) {
        print('iOS Simulator detected - returning mock token for development');
        String mockToken = 'simulator-mock-token-${DateTime.now().millisecondsSinceEpoch}';
        await _saveTokenLocally(mockToken);
        return mockToken;
      }
      
      String? token = await _messaging!.getToken();
      if (token != null) {
        print('Simulator FCM token obtained: $token');
        await _saveTokenLocally(token);
      }
      return token;
    } catch (e) {
      print('Error getting simulator token: $e');
      
      // Fallback to mock token for iOS simulator
      if (Platform.isIOS) {
        print('Falling back to mock token for iOS simulator');
        String mockToken = 'simulator-mock-token-${DateTime.now().millisecondsSinceEpoch}';
        await _saveTokenLocally(mockToken);
        return mockToken;
      }
      
      return null;
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
