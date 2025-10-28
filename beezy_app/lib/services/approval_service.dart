import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/approval_model.dart';

class ApprovalService {
  final String baseUrl = "http://192.168.1.2:5000/approvals/";

  // Approvals created by the logged-in user
  Future<List<ApprovalRecord>> getMyInitiatedApprovals(String token) async {
    final response = await http.get(
      Uri.parse("${baseUrl}approvals/my_requests/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<ApprovalRecord>.from(data.map((a) => ApprovalRecord.fromJson(a)));
    } else {
      throw Exception("Failed to load approvals created by user");
    }
  }

  // Approvals assigned to the logged-in user to approve
  Future<List<ApprovalRecord>> getApprovalsToApprove(String token) async {
    final response = await http.get(
      Uri.parse("${baseUrl}approvals/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<ApprovalRecord>.from(data.map((a) => ApprovalRecord.fromJson(a)));
    } else {
      throw Exception("Failed to load approvals to approve");
    }
  }

  // Approve a specific approval record
  Future<bool> approveRecord(int id, String token, {String? comment}) async {
    final response = await http.post(
      Uri.parse("${baseUrl}approvals/$id/approve/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"comment": comment ?? ""}),
    );

    return response.statusCode == 200;
  }

  // Reject a specific approval record
  Future<bool> rejectRecord(int id, String token, {String? comment}) async {
    final response = await http.post(
      Uri.parse("${baseUrl}approvals/$id/reject/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"comment": comment ?? ""}),
    );

    return response.statusCode == 200;
  }
}
