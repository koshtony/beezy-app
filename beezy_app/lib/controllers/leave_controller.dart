import 'package:flutter/material.dart';
import '../models/leave_model.dart';
import '../services/leave_service.dart';

class LeaveController extends ChangeNotifier {
  final LeaveService _service = LeaveService();

  List<Leave> myLeaves = [];
  List<Leave> approvals = [];

  bool loadingMyLeaves = false;
  bool loadingApprovals = false;

  Future<void> loadMyLeaves({bool forceRefresh = false}) async {
    if (loadingMyLeaves) return;
    loadingMyLeaves = true;
    notifyListeners();

    try {
      final fetched = await _service.getMyLeaves();
      // ✅ ensure unique items by ID
      final unique = <int, Leave>{};
      for (var leave in fetched) {
        if (leave.id != null) unique[leave.id!] = leave;
      }
      myLeaves = unique.values.toList();
      debugPrint("✅ Loaded ${myLeaves.length} unique leaves");
    } catch (e) {
      debugPrint("❌ Error loading leaves: $e");
    } finally {
      loadingMyLeaves = false;
      notifyListeners();
    }
  }

  Future<void> loadApprovals({bool forceRefresh = false}) async {
    if (loadingApprovals) return;
    loadingApprovals = true;
    notifyListeners();

    try {
      final fetched = await _service.getApprovals();
      final unique = <int, Leave>{};
      for (var leave in fetched) {
        if (leave.id != null) unique[leave.id!] = leave;
      }
      approvals = unique.values.toList();
      debugPrint("✅ Loaded ${approvals.length} unique approvals");
    } catch (e) {
      debugPrint("❌ Error loading approvals: $e");
    } finally {
      loadingApprovals = false;
      notifyListeners();
    }
  }

  Future<void> submitLeave(Leave leave) async {
    try {
      await _service.submitLeave(leave);
      await loadMyLeaves(forceRefresh: true);
    } catch (e) {
      debugPrint("❌ Error submitting leave: $e");
      rethrow;
    }
  }

  Future<void> approveLeave(int id) async {
    try {
      await _service.approveLeave(id);
      approvals.removeWhere((l) => l.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error approving leave: $e");
      rethrow;
    }
  }

  Future<void> rejectLeave(int id) async {
    try {
      await _service.rejectLeave(id);
      approvals.removeWhere((l) => l.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error rejecting leave: $e");
      rethrow;
    }
  }

  void clearAll() {
    myLeaves = [];
    approvals = [];
    notifyListeners();
  }
}
