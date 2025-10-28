import 'package:flutter/material.dart';
import '../services/attendance_service.dart';

class AttendanceController {
  final AttendanceService _attendanceService = AttendanceService();

  /// Fetch the logged-in user's profile
  Future<Map<String, dynamic>?> fetchProfile(BuildContext context) async {
    try {
      final response = await _attendanceService.fetchProfile();

      return response;
        } catch (e) {
      _showSnack(context, "❌ Failed to load profile: $e");
      return null;
    }
  }

  /// Perform check-in with geolocation
  Future<void> checkIn(
      BuildContext context, Map<String, dynamic> locationData) async {
    try {
      final response = await _attendanceService.checkIn(locationData);

      // ✅ Always convert response to a readable string
      final String message = response.toString() ?? "✅ Check-in successful!";

      _showSnack(
        context,
        message,
        success: message.toLowerCase().contains("success"),
      );
    } catch (e) {
      _showSnack(context, "⚠️ Check-in failed: $e");
    }
  }

  /// Helper to show consistent SnackBars
  void _showSnack(BuildContext context, String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
  }
}
