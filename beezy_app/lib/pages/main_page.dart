import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'attendance_page.dart';
import 'approval_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  int _index = 0;

  final _pages = [
    const Center(child: Text("Dashboard")),
    const ClockInPage(),
    const ApprovalPage(),
    const Center(child: Text("Leave Requests")),
    const Center(child: Text("Payroll")),
    const ProfilePage(),
  ];

  final _titles = [
    "Dashboard",
    "Clock In/Out",
    "Approvals",
    "Leave Requests",
    "Payroll",
    "Profile",
  ];

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabTapped(int i) {
    setState(() => _index = i);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // 🐝 Colors consistent with login page
    const beeGreen = Color.fromARGB(255, 8, 218, 85);
    const beeBlue = Colors.blueAccent;
    const backgroundColor = Color(0xFFF4F6F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _titles[_index],
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 3,
        centerTitle: true,
        shadowColor: beeBlue.withOpacity(0.1),
      ),

      body: Stack(
        children: [
          // 🐝 Faint bee emoji background
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.05, // faint and elegant
                child: const Text(
                  "🐝",
                  style: TextStyle(fontSize: 250), // large and subtle
                ),
              ),
            ),
          ),

          // Page transition animation
          FadeTransition(
            opacity: _animation,
            child: _pages[_index],
          ),
        ],
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: beeBlue.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: _index,
            onTap: _onTabTapped,
            selectedItemColor: beeBlue,
            unselectedItemColor: Colors.grey.shade500,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time_rounded),
                label: "Clock",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.verified_rounded),
                label: "Approvals",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.beach_access_rounded),
                label: "Leave",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded),
                label: "Payroll",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
