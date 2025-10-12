import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ⚙️ Update with your actual backend IP and port
  final String baseUrl = 'http://192.168.1.3:5000/users/';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ Save JWT tokens locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access', data['access']);
      await prefs.setString('refresh', data['refresh']);

      return data;
    } else if (response.statusCode == 403) {
      throw Exception('Account inactive. Awaiting admin approval.');
    } else if (response.statusCode == 400) {
      throw Exception('Invalid username or password.');
    } else {
      throw Exception('Login failed. Please try again later.');
    }
  }
}
