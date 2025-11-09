import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://192.168.1.3:5000/users/';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      // ✅ Save tokens
      await prefs.setString('access', data['access']);
      await prefs.setString('refresh', data['refresh']);

      // ✅ Save employee info if returned
      if (data['user'] != null) {
        await prefs.setInt('employeeId', data['user']['id']);
        await prefs.setString('employeeCode', data['user']['employee_code'] ?? '');
        await prefs.setString('employeeName',
            "${data['user']['first_name'] ?? ''} ${data['user']['last_name'] ?? ''}".trim());
      }

      return data;
    } else if (response.statusCode == 403) {
      throw Exception('Account inactive. Awaiting admin approval.');
    } else if (response.statusCode == 400) {
      throw Exception('Invalid username or password.');
    } else {
      throw Exception('Login failed. Please try again later.');
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access');
  }

  static Future<int?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('employeeId');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
