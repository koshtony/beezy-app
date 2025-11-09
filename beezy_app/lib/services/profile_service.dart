import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final String baseUrl = 'http://192.168.1.3:5000';

  Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access');

    if (token == null) throw Exception("Not logged in");

    final response = await http.get(
      Uri.parse('$baseUrl/users/employees/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // ✅ Handle both list and map responses
      if (decoded is List && decoded.isNotEmpty) {
        return decoded.first as Map<String, dynamic>;
      } else if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        throw Exception("Unexpected API response format");
      }
    } else {
      throw Exception('Failed to load profile (${response.statusCode})');
    }
  }
}
