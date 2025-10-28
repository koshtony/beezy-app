import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? token;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    if (token != null && mounted) {
      await Provider.of<ApprovalController>(context, listen: false)
          .loadData(token!);
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
        return const Color(0xFF08DA55); // Beezy Green
      case "rejected":
        return const Color(0xFFD32F2F);
      case "pending":
      default:
        return const Color(0xFF1976D2); // Beezy Blue
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
            
            
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
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
              // 🐝 Soft Bee Emoji background
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: 0.05,
                    child: const Text(
                      "🐝",
                      style: TextStyle(fontSize: 250),
                    ),
                  ),
                ),
              ),

              controller.loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(
                          controller.initiated,
                          "You haven't initiated any approvals yet.",
                        ),
                        _buildList(
                          controller.toApprove,
                          "No approvals pending for you.",
                        ),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(List<ApprovalRecord> approvals, String emptyMessage) {
    if (approvals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_unread_outlined,
                  size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (token != null) {
          await Provider.of<ApprovalController>(context, listen: false)
              .loadData(token!);
        }
      },
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
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: _statusColor(item.status).withOpacity(0.15),
                child: Icon(
                  Icons.assignment_turned_in_rounded,
                  color: _statusColor(item.status),
                ),
              ),
              title: Text(
                item.approvalType ?? "Unknown Type",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text(
                        item.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: _statusColor(item.status),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    if (item.comment != null && item.comment!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Comment: ${item.comment}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      "Level: ${item.level ?? '-'}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 🌈 Custom Gradient Tab Indicator
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
    final rect = Offset(offset.dx, cfg.size!.height - thickness) &
        Size(cfg.size!.width, thickness);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);
  }
}
