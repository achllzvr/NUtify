import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserStatusService {
  static const String _baseUrl = 'https://nutify.site/api.php';
  static const List<String> allowed = ['online', 'busy', 'offline'];
  static List<String> _allowedCache = List.from(allowed);

  // Attempt to fetch allowed statuses from backend; fallback to cache/default
  static Future<List<String>> fetchAllowedStatuses() async {
    try {
      final resp = await http.get(Uri.parse('$_baseUrl?action=getAllowedUserStatuses'));
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final data = jsonDecode(resp.body);
        // accept either { statuses: ['online', ...] } or a raw list
        final list = (data is List)
            ? List<String>.from(data.map((e) => e.toString()))
            : (data is Map && data['statuses'] is List)
                ? List<String>.from((data['statuses'] as List).map((e) => e.toString()))
                : null;
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
        body: jsonEncode({'user_id': userId}),
      );
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final data = jsonDecode(resp.body);
        if (data['status'] == 'success') {
          final s = (data['data']?['user_status'] ?? '').toString();
          // Accept any string; caller may still show as-is. Validation occurs on update.
          if (s.isNotEmpty) return s;
        }
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

      final resp = await http.post(
        Uri.parse('$_baseUrl?action=updateUserStatus'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'user_status': status}),
      );
      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final data = jsonDecode(resp.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
