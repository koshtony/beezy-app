import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'attendance_page.dart';

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
    const Center(child: Text("Approvals")),
    const Center(child: Text("Leave")),
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          _titles[_index],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 4,
        shadowColor: Colors.blueAccent.withOpacity(0.1),
        centerTitle: true,
      ),

      body: FadeTransition(
        opacity: _animation,
        child: _pages[_index],
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.15),
              blurRadius: 12,
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
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Clock"),
              BottomNavigationBarItem(icon: Icon(Icons.verified_rounded), label: "Approvals"),
              BottomNavigationBarItem(icon: Icon(Icons.beach_access_rounded), label: "Leave"),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "Payroll"),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}
