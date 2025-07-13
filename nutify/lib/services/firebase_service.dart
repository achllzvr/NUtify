import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseMessaging? _messaging;

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
  }

  // Get current FCM token
  Future<String?> getToken() async {
    if (_messaging == null) return null;

    try {
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
