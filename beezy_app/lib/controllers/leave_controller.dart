import 'package:flutter/material.dart';
import '../models/leave_model.dart';
import '../services/leave_service.dart';

class LeaveController extends ChangeNotifier {
  final LeaveService _service = LeaveService();

  List<Leave> myLeaves = [];
  List<Leave> approvals = [];
  bool loading = false;

  Future<void> loadLeaves() async {
    loading = true;
    notifyListeners();
    try {
      myLeaves = await _service.getMyLeaves();
    } catch (e) {
      debugPrint("❌ Error loading leaves: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadApprovals() async {
    loading = true;
    notifyListeners();
    try {
      approvals = await _service.getApprovals();
    } catch (e) {
      debugPrint("❌ Error loading approvals: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> submitLeave(Leave leave) async {
    await _service.submitLeave(leave);
    await loadLeaves();
  }

  Future<void> approveLeave(int id) async {
    await _service.approveLeave(id);
    await loadApprovals();
  }

  Future<void> rejectLeave(int id) async {
    await _service.rejectLeave(id);
    await loadApprovals();
  }
}
