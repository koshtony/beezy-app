// lib/pages/leave_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/leave_controller.dart';
import '../models/leave_model.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  int? _selectedLeaveTypeId;
  String? _selectedLeaveTypeName;
  bool _isHalfDay = false;
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalDays = 0;
  File? _attachment;
  final TextEditingController _reasonController = TextEditingController();

  // demo leave types (you can fetch these from API later)
  final List<Map<String, dynamic>> _leaveTypes = [
    {"id": 1, "name": "Annual Leave"},
    {"id": 2, "name": "Sick Leave"},
    {"id": 3, "name": "Maternity Leave"},
    {"id": 4, "name": "Paternity Leave"},
    {"id": 5, "name": "Compassionate Leave"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // ✅ Run after widget is built to avoid double calls or rebuild race
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<LeaveController>(context, listen: false);
      controller.loadMyLeaves();
      controller.loadApprovals();
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _calculateTotalDays();
      });
    }
  }

  void _calculateTotalDays() {
    if (_startDate != null && _endDate != null) {
      final days = _endDate!.difference(_startDate!).inDays + 1;
      _totalDays = _isHalfDay ? 0.5 : days.toDouble();
    } else {
      _totalDays = 0;
    }
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() => _attachment = File(result.files.single.path!));
    }
  }

  Future<void> _submitLeave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select start and end dates")),
      );
      return;
    }

    final leave = Leave(
      leaveTypeId: _selectedLeaveTypeId!,
      startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
      endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
      dayType: _isHalfDay ? 'half' : 'full',
      totalDays: _totalDays,
      reason: _reasonController.text,
    );

    final controller = Provider.of<LeaveController>(context, listen: false);

    try {
      await controller.submitLeave(leave);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Leave submitted successfully")),
        );
        _resetForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to submit leave: $e")),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedLeaveTypeId = null;
      _selectedLeaveTypeName = null;
      _startDate = null;
      _endDate = null;
      _isHalfDay = false;
      _attachment = null;
      _totalDays = 0;
    });
    _reasonController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LeaveController>(context);

    final bool loadingAny =
        controller.loadingMyLeaves || controller.loadingApprovals;

    return Stack(
      children: [
        // Bee background
        Positioned.fill(
          child: Opacity(
            opacity: 0.05,
            child: Center(child: Text("🐝", style: const TextStyle(fontSize: 200))),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Leave Management", style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.green.shade800,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green.shade700,
              tabs: const [
                Tab(icon: Icon(Icons.add_task), text: "Apply"),
                Tab(icon: Icon(Icons.approval), text: "Approvals"),
              ],
            ),
          ),
          body: loadingAny
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // --- My Leaves tab ---
                    _buildMyLeavesTab(controller),
                    // --- To Approve tab ---
                    _buildApprovalsTab(controller),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMyLeavesTab(LeaveController controller) {
    // show apply form + list of my leaves below
    return RefreshIndicator(
      onRefresh: controller.loadMyLeaves,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Apply form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    value: _selectedLeaveTypeId,
                    items: _leaveTypes
                        .map((type) => DropdownMenuItem<int>(
                              value: type["id"],
                              child: Text(type["name"]),
                            ))
                        .toList(),
                    decoration: const InputDecoration(labelText: "Leave Type"),
                    onChanged: (value) {
                      final selected = _leaveTypes.firstWhere((t) => t["id"] == value);
                      setState(() {
                        _selectedLeaveTypeId = value;
                        _selectedLeaveTypeName = selected["name"];
                      });
                    },
                    validator: (value) => value == null ? "Select leave type" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(labelText: "Reason"),
                    maxLines: 3,
                    validator: (v) => v == null || v.isEmpty ? "Enter a reason" : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDateRange,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _startDate == null
                                ? "Select Date Range"
                                : "${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d, yyyy').format(_endDate!)}",
                          ),
                        ),
                      ),
                      Checkbox(
                        value: _isHalfDay,
                        onChanged: (v) {
                          setState(() {
                            _isHalfDay = v ?? false;
                            _calculateTotalDays();
                          });
                        },
                      ),
                      const Text("Half Day"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_totalDays > 0)
                    Text("Total Days: $_totalDays",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickAttachment,
                    icon: const Icon(Icons.attach_file),
                    label: Text(_attachment == null
                        ? "Attach File (Optional)"
                        : "File: ${_attachment!.path.split('/').last}"),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _submitLeave,
                      icon: const Icon(Icons.send),
                      label: const Text("Submit Leave"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Your requests", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // My leaves list
            if (controller.myLeaves.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text("You have no leave requests")),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.myLeaves.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final l = controller.myLeaves[i];
                  return _buildLeaveCard(l, showProgress: true);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalsTab(LeaveController controller) {
    if (controller.approvals.isEmpty) {
      return const Center(child: Text("No pending approvals"));
    }

    return RefreshIndicator(
      onRefresh: controller.loadApprovals,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: controller.approvals.length,
        itemBuilder: (context, i) {
          final leave = controller.approvals[i];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: Text("${leave.employeeName ?? 'Employee'} - ${leave.leaveTypeName ?? ''}"),
              subtitle: Text("${leave.startDate} → ${leave.endDate}\nStatus: ${leave.status}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () async {
                      try {
                        await controller.approveLeave(leave.id!);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Approved")));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Approve failed: $e")));
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.redAccent),
                    onPressed: () async {
                      try {
                        await controller.rejectLeave(leave.id!);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rejected")));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Reject failed: $e")));
                      }
                    },
                  ),
                ],
              ),
              onTap: () => _showLeaveDetails(leave),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaveCard(Leave l, {bool showProgress = false}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text("${l.leaveTypeName ?? ''} — ${l.totalDays} day(s)"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${l.startDate} → ${l.endDate}"),
            const SizedBox(height: 6),
            Text("Status: ${l.status}"),
            if (showProgress && (l.approvalRecords != null && l.approvalRecords!.isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildApprovalTimeline(l),
              ),
          ],
        ),
        isThreeLine: true,
        onTap: () => _showLeaveDetails(l),
      ),
    );
  }

  /// Builds approval timeline safely whether approval records are objects or Maps
  Widget _buildApprovalTimeline(Leave l) {
    final records = l.approvalRecords ?? [];
    if (records.isEmpty) {
      return const Text("No approvals yet", style: TextStyle(fontSize: 12, color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: records.map((raw) {
        // raw could be ApprovalRecord instance OR Map<String, dynamic>
        String action;
        String approverName;
        String? remarks;
        String? timestamp;

        if (raw is Map) {
          action = (raw['action'] ?? raw['status'] ?? 'pending').toString();
          approverName = (raw['approver_name'] ??
                  raw['approver_full_name'] ??
                  raw['approver']?.toString() ??
                  'Approver')
              .toString();
          remarks = raw['remarks']?.toString();
          timestamp = raw['timestamp']?.toString();
        } else {
          // try to read fields; using dynamic access to avoid runtime exceptions
          try {
            final dynamic r = raw;
            action = (r.action ?? r['action'] ?? 'pending').toString();
          } catch (_) {
            action = 'pending';
          }
          try {
            final dynamic r = raw;
            approverName = (r.approverName ?? r.approver_name ?? 'Approver').toString();
          } catch (_) {
            approverName = 'Approver';
          }
          try {
            final dynamic r = raw;
            remarks = (r.remarks ?? r['remarks'])?.toString();
          } catch (_) {
            remarks = null;
          }
          try {
            final dynamic r = raw;
            timestamp = (r.timestamp ?? r['timestamp'])?.toString();
          } catch (_) {
            timestamp = null;
          }
        }

        Color color;
        IconData icon;

        switch (action.toLowerCase()) {
          case 'approved':
            color = Colors.green;
            icon = Icons.check_circle;
            break;
          case 'rejected':
            color = Colors.red;
            icon = Icons.cancel;
            break;
          case 'pending':
          default:
            color = Colors.orange;
            icon = Icons.hourglass_empty;
        }

        return Padding(
          key: ValueKey(approverName + action + (timestamp ?? '')),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$approverName — ${action.toUpperCase()}",
                      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    if (remarks != null && remarks.isNotEmpty)
                      Text(
                        "Remarks: $remarks",
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    if (timestamp != null && timestamp.isNotEmpty)
                      Text(
                        "At: $timestamp",
                        style: const TextStyle(fontSize: 11, color: Colors.black45),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showLeaveDetails(Leave l) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Leave #${l.id ?? ''}"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Type: ${l.leaveTypeName ?? ''}"),
                const SizedBox(height: 6),
                Text("Dates: ${l.startDate} → ${l.endDate}"),
                const SizedBox(height: 6),
                Text("Days: ${l.totalDays}"),
                const SizedBox(height: 6),
                Text("Reason: ${l.reason}"),
                const SizedBox(height: 6),
                Text("Status: ${l.status}"),
                const SizedBox(height: 12),
                if (l.approvalRecords != null && l.approvalRecords!.isNotEmpty) ...[
                  const Divider(),
                  const Text("Approvals:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  _buildApprovalTimeline(l),
                ],
                if (l.attachmentUrl != null && l.attachmentUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("📎 Attachment available"),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          ],
        );
      },
    );
  }
}
