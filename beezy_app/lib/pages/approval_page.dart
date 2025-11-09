import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/approval_controller.dart';
import '../models/approval_model.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      await Provider.of<ApprovalController>(context, listen: false)
          .refreshAll();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return const Color(0xFF08DA55);
      case "rejected":
        return const Color(0xFFD32F2F);
      case "pending":
      default:
        return const Color(0xFF1976D2);
    }
  }

  @override
  Widget build(BuildContext context) {
    const beeBlue = Color(0xFF1976D2);
    const beeGreen = Color(0xFF08DA55);
    const bgColor = Color(0xFFF4F6F8);

    return Consumer<ApprovalController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            title: const Text(
              "Approvals",
              style: TextStyle(color: Colors.black87),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: beeBlue,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicator: GradientTabIndicator(
                    gradient: const LinearGradient(
                      colors: [beeGreen, beeBlue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    thickness: 3,
                  ),
                  tabs: const [
                    Tab(icon: Icon(Icons.send_rounded), text: "My Requests"),
                    Tab(icon: Icon(Icons.task_alt_rounded), text: "To Approve"),
                  ],
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: 0.05,
                    child: const Text("🐝", style: TextStyle(fontSize: 250)),
                  ),
                ),
              ),
              controller.loadingApprovals
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(controller.initiated, "You haven't initiated any approvals yet.", controller),
                        _buildList(controller.toApprove, "No approvals pending for you.", controller),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(List<ApprovalRecord> approvals, String emptyMessage, ApprovalController controller) {
    if (approvals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_unread_outlined, size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(emptyMessage, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.loadApprovals,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: approvals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final item = approvals[i];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: _statusColor(item.status).withOpacity(0.15),
                child: Icon(Icons.assignment_turned_in_rounded, color: _statusColor(item.status)),
              ),
              title: Text(item.approvalType ?? "Unknown Type", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(item.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    backgroundColor: _statusColor(item.status),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  if (item.comment != null && item.comment!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text("Comment: ${item.comment}", style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    ),
                  const SizedBox(height: 4),
                  Text("Level: ${item.level ?? '-'}", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 6),
                  if (item.status.toLowerCase() == "pending")
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showApprovalDialog(controller, item, true),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text("Approve"),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF08DA55)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showApprovalDialog(controller, item, false),
                          icon: const Icon(Icons.close_rounded),
                          label: const Text("Reject"),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showApprovalDialog(ApprovalController controller, ApprovalRecord record, bool isApprove) {
    final TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isApprove ? "Approve Request" : "Reject Request"),
        content: TextField(controller: commentController, decoration: const InputDecoration(hintText: "Add a comment (optional)"), maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (isApprove) {
                await controller.approve(record.id, comment: commentController.text);
              } else {
                await controller.reject(record.id, comment: commentController.text);
              }
            },
            child: Text(isApprove ? "Approve" : "Reject"),
          ),
        ],
      ),
    );
  }
}

// GradientTabIndicator class remains unchanged
class GradientTabIndicator extends Decoration {
  final LinearGradient gradient;
  final double thickness;
  const GradientTabIndicator({required this.gradient, this.thickness = 3});
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _GradientPainter(gradient: gradient, thickness: thickness);
  }
}

class _GradientPainter extends BoxPainter {
  final LinearGradient gradient;
  final double thickness;
  _GradientPainter({required this.gradient, this.thickness = 3});
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final rect = Offset(offset.dx, cfg.size!.height - thickness) & Size(cfg.size!.width, thickness);
    final paint = Paint()..shader = gradient.createShader(rect)..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);
  }
}
