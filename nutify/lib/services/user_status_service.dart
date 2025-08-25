import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserStatusService {
  static const String _baseUrl = 'https://nutify.site/api.php';
  static const List<String> allowed = ['online', 'busy', 'offline'];

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
          if (allowed.contains(s)) return s;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> updateStatus(String status) async {
    if (!allowed.contains(status)) return false;
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
