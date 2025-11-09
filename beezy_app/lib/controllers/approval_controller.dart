import 'package:flutter/material.dart';
import '../models/approval_model.dart';
import '../services/approval_service.dart';

class ApprovalController extends ChangeNotifier {
  final ApprovalService _service = ApprovalService();

  // ===============================
  // STATE VARIABLES
  // ===============================
  List<ApprovalRecord> initiated = [];
  List<ApprovalRecord> toApprove = [];
  List<NotificationModel> notifications = [];
  int unreadCount = 0;

  bool loadingApprovals = false;
  bool loadingNotifications = false;
  String? errorMessage;

  // ===============================
  // LOAD APPROVALS
  // ===============================
  Future<void> loadApprovals() async {
    loadingApprovals = true;
    errorMessage = null;
    notifyListeners();

    try {
      initiated = await _service.getMyInitiatedApprovals();
      toApprove = await _service.getApprovalsToApprove();
    } catch (e) {
      debugPrint("❌ Error loading approvals: $e");
      errorMessage = e.toString();
    } finally {
      loadingApprovals = false;
      notifyListeners();
    }
  }

  // ===============================
  // APPROVE / REJECT
  // ===============================
  Future<void> approve(int id, {String? comment}) async {
    try {
      await _service.approveRecord(id, comment: comment);
      await loadApprovals();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("❌ Failed to approve: $e");
      notifyListeners();
    }
  }

  Future<void> reject(int id, {String? comment}) async {
    try {
      await _service.rejectRecord(id, comment: comment);
      await loadApprovals();
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("❌ Failed to reject: $e");
      notifyListeners();
    }
  }

  // ===============================
  // NOTIFICATIONS
  // ===============================
  Future<void> loadNotifications({String? status}) async {
    loadingNotifications = true;
    notifyListeners();

    try {
      notifications = await _service.getNotifications(status: status);
      unreadCount = await _service.getUnreadCount();
    } catch (e) {
      debugPrint("❌ Failed to load notifications: $e");
    } finally {
      loadingNotifications = false;
      notifyListeners();
    }
  }

  // ===============================
  // REFRESH ALL
  // ===============================
  Future<void> refreshAll() async {
    await Future.wait([
      loadApprovals(),
      loadNotifications(),
    ]);
  }
}
