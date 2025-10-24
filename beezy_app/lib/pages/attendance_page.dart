import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/attendance_controller.dart';

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});

  @override
  State<ClockInPage> createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  final AttendanceController _controller = AttendanceController();
  bool _loading = true;
  Map<String, dynamic>? _profile;
  List<dynamic> _stations = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _controller.fetchProfile(context);
    if (data != null) {
      setState(() {
        _profile = data;
        _stations = data['stations'] ?? [];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  /// ✅ Get current location safely with permissions
  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack('❌ Location services are disabled.');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack('❌ Location permissions denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnack('⚠️ Location permissions permanently denied.');
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// ✅ Perform check-in using current GPS location
  Future<void> _checkIn() async {
    try {
      final position = await _getCurrentPosition();
      if (position == null) return;

      await _controller.checkIn(context, {
        "latitude": position.latitude,
        "longitude": position.longitude,
      });
    } catch (e) {
      _showSnack("⚠️ Failed to get location: $e");
    }
  }

  void _showSnack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Clock In')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 👇 Station Info Scroll
            SizedBox(
              height: 120,
              child: _stations.isNotEmpty
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _stations.length,
                      itemBuilder: (context, index) {
                        final station = _stations[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.only(right: 12),
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  station['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  station['address'] ?? '',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📍 ${station['latitude']}, ${station['longitude']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text("No stations assigned")),
            ),

            const Spacer(),

            // 👇 Big Round Check-In Button
            Center(
              child: ElevatedButton(
                onPressed: _checkIn,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(60),
                  backgroundColor: Colors.blue,
                  elevation: 10,
                ),
                child: const Icon(Icons.access_time,
                    color: Colors.white, size: 50),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
