import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<bool> login(BuildContext context, String username, String password) async {
    try {
      await _authService.login(username, password);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
      return false;
    }
  }
}

