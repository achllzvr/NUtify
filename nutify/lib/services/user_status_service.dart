import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserStatusService {
  static const String _baseUrl = 'https://nutify.site/api.php';
  // Default cycle order when backend doesn't provide allowed statuses
  // Include expanded set per app spec so teachers can select new statuses by default
  static const List<String> allowed = [
    'online',
    'in-class',
    'in-meeting',
    'busy',
    'offline',
  ];
  static List<String> _allowedCache = List.from(allowed);

  // Attempt to fetch allowed statuses from backend; fallback to cache/default
  static Future<List<String>> fetchAllowedStatuses() async {
    try {
      final resp = await http.get(Uri.parse('$_baseUrl?action=getAllowedUserStatuses'));
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final data = jsonDecode(resp.body);
        // accept common shapes
        List<String>? list;
        if (data is List) {
          list = List<String>.from(data.map((e) => e.toString()));
        } else if (data is Map) {
          if (data['statuses'] is List) {
            list = List<String>.from((data['statuses'] as List).map((e) => e.toString()));
          } else if (data['data'] is List) {
            list = List<String>.from((data['data'] as List).map((e) => e.toString()));
          } else if (data['allowed'] is List) {
            list = List<String>.from((data['allowed'] as List).map((e) => e.toString()));
          }
        }
        if (list != null && list.isNotEmpty) {
          _allowedCache = list;
          return _allowedCache;
        }
      }
    } catch (_) {}
    return _allowedCache;
  }

  static Future<String?> fetchStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) return null;

      final resp = await http.post(
        Uri.parse('$_baseUrl?action=getUserStatus'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'userID': userId}),
      );
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final data = jsonDecode(resp.body);
        String? s;
        if (data is Map) {
          if (data['status'] == 'success') {
            s = (data['data']?['user_status'] ?? data['data']?['status'] ?? '').toString();
          } else if (data['success'] == true) {
            s = (data['user_status'] ?? data['status'] ?? data['data'] ?? '').toString();
          } else if (data['user_status'] != null) {
            s = data['user_status'].toString();
          } else if (data['status'] is String) {
            // Be careful: servers often use 'status' for success marker, but if string and not 'success', treat as value
            final val = data['status'].toString().toLowerCase();
            if (val != 'success' && val != 'ok') s = data['status'].toString();
          }
        } else if (data is String) {
          s = data;
        }
        if (s != null && s.isNotEmpty) return s;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> updateStatus(String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) return false;

      final endpoints = <String>[
        'updateUserStatus',
        'setUserStatus',
        'updateStatus',
        'changeUserStatus',
      ];
      final payloads = <Map<String, dynamic>>[
        {'user_id': userId, 'user_status': status},
        {'userID': userId, 'user_status': status},
        {'user_id': userId, 'status': status},
        {'userID': userId, 'status': status},
      ];

      for (final action in endpoints) {
        for (final body in payloads) {
          try {
            final resp = await http.post(
              Uri.parse('$_baseUrl?action=$action'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            );
            if (resp.statusCode == 200 && resp.body.isNotEmpty) {
              final data = jsonDecode(resp.body);
              final ok = (data is Map) && ((data['status'] == 'success') || (data['success'] == true) || (data['result'] == 'success'));
              if (ok) return true;
            }
          } catch (_) {
            // try next combination
          }
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
