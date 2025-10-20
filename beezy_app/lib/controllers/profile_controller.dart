import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class ProfileController {
  final ProfileService _profileService = ProfileService();

  Future<Map<String, dynamic>?> fetchProfile(BuildContext context) async {
    try {
      return await _profileService.getProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
      );
      return null;
    }
  }
}
