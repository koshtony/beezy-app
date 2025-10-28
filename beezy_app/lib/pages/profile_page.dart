import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _controller = ProfileController();
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _controller.fetchProfile(context);
      setState(() {
        _profile = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color beezyGold = Color(0xFFFFC107); // Beezy golden yellow
    const Color softCream = Color(0xFFFFF9E5); // Background cream
    const Color darkText = Color(0xFF2E2A1E);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return const Scaffold(
        body: Center(child: Text("No profile data found")),
      );
    }

    String? imageUrl = _profile!['image_url'];

    return Scaffold(
      backgroundColor: softCream,
      body: Stack(
        children: [
          // 🐝 Deemly Bee Background
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Text(
                  "🐝",
                  style: TextStyle(
                    fontSize: 200,
                    color: Colors.black.withOpacity(0.04),
                  ),
                ),
              ),
            ),
          ),

          // 🟡 Golden Header Gradient
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFFFFECB3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
          ),

          // 🔹 Main Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "My Profile",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 10),

                // 🧑 Profile Card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 60),
                              padding: const EdgeInsets.only(
                                  top: 80, bottom: 20, left: 20, right: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    _profile!['full_name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Employee Code: ${_profile!['employee_code'] ?? '-'}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // 🧾 Info Cards
                                  _buildInfoCard("Department",
                                      _profile!['department_name']),
                                  _buildInfoCard("Sub Department",
                                      _profile!['sub_department_name']),
                                  _buildInfoCard(
                                      "Gender", _profile!['gender']),
                                  _buildInfoCard("Marital Status",
                                      _profile!['marital_status']),
                                  _buildInfoCard("Employment Type",
                                      _profile!['employment_type']),
                                  _buildInfoCard("Date Joined",
                                      _profile!['date_of_joining']),
                                  _buildInfoCard(
                                      "Address", _profile!['address']),
                                ],
                              ),
                            ),

                            // 🖼️ Profile Image Floating
                            Positioned(
                              top: 0,
                              child: Hero(
                                tag: "profile_image",
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  backgroundImage: (imageUrl != null &&
                                          imageUrl.isNotEmpty)
                                      ? NetworkImage(imageUrl)
                                      : const AssetImage(
                                              'assets/images/default_user.png')
                                          as ImageProvider,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, dynamic value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E2A1E),
            ),
          ),
          Flexible(
            child: Text(
              value?.toString() ?? '-',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
