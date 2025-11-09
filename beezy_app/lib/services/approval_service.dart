import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/approval_model.dart';
import 'auth_service.dart';

class ApprovalService {
  final String baseUrl = "http://192.168.1.3:5000/approvals/";

  // 🔑 Helper to fetch access token
  Future<String?> _getToken() async {
    return await AuthService.getAccessToken();
  }

  // ===============================
  // APPROVALS
  // ===============================

  // 🧾 Approvals initiated by logged-in user
  Future<List<ApprovalRecord>> getMyInitiatedApprovals() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse("${baseUrl}approvals/my-requests/"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("🟡 My Initiated Approvals Response: ${res.statusCode} -> ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded.map((e) => ApprovalRecord.fromJson(e)).toList();
      } else if (decoded is Map && decoded['results'] is List) {
        return (decoded['results'] as List)
            .map((e) => ApprovalRecord.fromJson(e))
            .toList();
      } else {
        throw Exception("Unexpected data format from server.");
      }
    }
    throw Exception("Failed to load my initiated approvals: ${res.body}");
  }

  // 🧾 Approvals pending for the logged-in user
  Future<List<ApprovalRecord>> getApprovalsToApprove() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse("${baseUrl}approvals/"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("🟡 Pending Approvals Response: ${res.statusCode} -> ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded.map((e) => ApprovalRecord.fromJson(e)).toList();
      } else if (decoded is Map && decoded['results'] is List) {
        return (decoded['results'] as List)
            .map((e) => ApprovalRecord.fromJson(e))
            .toList();
      } else {
        throw Exception("Unexpected data format from server.");
      }
    }
    throw Exception("Failed to load approvals to approve: ${res.body}");
  }

  // ✅ Approve an approval record
  Future<void> approveRecord(int id, {String? comment}) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse("${baseUrl}approvals/$id/approve/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"comment": comment ?? ""}),
    );

    print("🟢 Approve Response ($id): ${res.statusCode} -> ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to approve record: ${res.body}");
    }
  }

  // ❌ Reject an approval record
  Future<void> rejectRecord(int id, {String? comment}) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse("${baseUrl}approvals/$id/reject/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"comment": comment ?? ""}),
    );

    print("🔴 Reject Response ($id): ${res.statusCode} -> ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to reject record: ${res.body}");
    }
  }

  // ===============================
  // NOTIFICATIONS
  // ===============================

  Future<List<NotificationModel>> getNotifications({String? status}) async {
    final token = await _getToken();
    String url = "${baseUrl}notifications/";
    if (status != null) url += "?status=$status";

    final res = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("🟡 Notifications Response: ${res.statusCode} -> ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded.map((e) => NotificationModel.fromJson(e)).toList();
      } else if (decoded is Map && decoded['results'] is List) {
        return (decoded['results'] as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      } else {
        throw Exception("Unexpected notifications format");
      }
    }

    throw Exception("Failed to load notifications: ${res.body}");
  }

  Future<void> markNotificationRead(int id) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse("${baseUrl}notifications/$id/mark-read/"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("✅ Mark Notification Read ($id): ${res.statusCode} -> ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to mark notification read: ${res.body}");
    }
  }

  Future<int> getUnreadCount() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse("${baseUrl}notifications/unread-count/"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['unread_count'] ?? 0;
    } else {
      throw Exception("Failed to get unread count: ${res.body}");
    }
  }
}
