import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'attendance_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  final _pages = [
    const Center(child: Text("Dashboard")),
    const Center(child: ClockInPage()),
    const Center(child: Text("Approvals")),
    const Center(child: Text("Leave")),
    const Center(child: Text("Payroll")),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HR Management"),
        backgroundColor: Colors.blueAccent,
      ),

      // ✅ Sidebar Drawer Menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              accountName: Text("John Doe"),
              accountEmail: Text("john.doe@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blueAccent, size: 35),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _index = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text("Clock In/Out"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _index = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text("Approvals"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _index = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.beach_access),
              title: const Text("Leave"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _index = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text("Payroll"),
              onTap: () {
                Navigator.pop(context);
                setState(() => _index = 4);
              },
            ),
            const Divider(),


            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement logout logic
              },
            ),
          ],
        ),
      ),

      // ✅ Main Page Body
      body: _pages[_index],

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Clock"),
          BottomNavigationBarItem(icon: Icon(Icons.verified), label: "Approvals"),
          BottomNavigationBarItem(icon: Icon(Icons.beach_access), label: "Leave"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Payroll"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
