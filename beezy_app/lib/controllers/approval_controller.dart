import 'package:flutter/material.dart';
import '../models/approval_model.dart';
import '../services/approval_service.dart';

class ApprovalController extends ChangeNotifier {
  final ApprovalService _service = ApprovalService();

  List<ApprovalRecord> initiated = [];
  List<ApprovalRecord> toApprove = [];
  bool loading = false;
  String? errorMessage;

  Future<void> loadData(String token) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      initiated = await _service.getMyInitiatedApprovals(token);
      toApprove = await _service.getApprovalsToApprove(token);
    } catch (e) {
      debugPrint("❌ Error loading approvals: $e");
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> approve(int id, String token, {String? comment}) async {
    try {
      await _service.approveRecord(id, token, comment: comment);
      await loadData(token);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("❌ Failed to approve: $e");
      notifyListeners();
    }
  }

  Future<void> reject(int id, String token, {String? comment}) async {
    try {
      await _service.rejectRecord(id, token, comment: comment);
      await loadData(token);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("❌ Failed to reject: $e");
      notifyListeners();
    }
  }
}
