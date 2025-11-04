import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/leave_model.dart';
import 'auth_service.dart';

class LeaveService {
  // ✅ Point to Django's leave routes (matches urls.py)
  final String baseUrl = "http://192.168.1.2:5000/leave/leave/";

  // 🔑 Helper to fetch access token
  Future<String?> _getToken() async {
    return await AuthService.getAccessToken();
  }

  // 🧾 Get all leaves applied by the logged-in user
  Future<List<Leave>> getMyLeaves() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse("${baseUrl}requests/my_leaves/"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Leave.fromJson(e)).toList();
    }
    throw Exception("Failed to load my leaves: ${res.body}");
  }

  // 🧾 Get all pending leaves that require approval
  Future<List<Leave>> getApprovals() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse("${baseUrl}requests/to_approve/"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Leave.fromJson(e)).toList();
    }
    throw Exception("Failed to load approvals: ${res.body}");
  }

  // 📝 Submit a new leave request
  Future<void> submitLeave(Leave leave) async {
  final token = await _getToken();
  final employeeId = await AuthService.getEmployeeId(); // ✅ pull from saved session

  final body = leave.toJson();
  body['employee'] = employeeId; // ✅ add employee field for Django

  final res = await http.post(
    Uri.parse("${baseUrl}requests/"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(body),
  );

  if (res.statusCode != 201) {
    throw Exception("Failed to submit leave: ${res.body}");
  }
}


  // ✅ Approve a leave request
  Future<void> approveLeave(int id) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse("${baseUrl}requests/$id/approve/"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to approve leave: ${res.body}");
    }
  }

  // ❌ Reject a leave request
  Future<void> rejectLeave(int id, {String? remarks}) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse("${baseUrl}requests/$id/reject/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"remarks": remarks ?? ""}),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to reject leave: ${res.body}");
    }
  }
}
