import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../controllers/attendance_controller.dart';

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});

  @override
  State<ClockInPage> createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  final AttendanceController _controller = AttendanceController();
  bool _loading = true;
  bool _checkedIn = false;
  bool _checkedOut = false;
  String _currentTime = "";
  Map<String, dynamic>? _profile;
  List<dynamic> _stations = [];

  CameraController? _cameraController;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _initializeCamera();
    _updateTimeEverySecond();
  }

  void _updateTimeEverySecond() {
    _currentTime = _formatTime(DateTime.now());
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _currentTime = _formatTime(DateTime.now()));
      return true;
    });
  }

  String _formatTime(DateTime now) {
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
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

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController =
          CameraController(frontCamera, ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack('❌ Location services disabled.');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack('❌ Location permission denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnack('⚠️ Location permission permanently denied.');
      return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<XFile?> _capturePhoto() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        await _initializeCamera();
      }

      final image = await _cameraController!.takePicture();
      setState(() => _capturedImage = image);
      return image;
    } catch (e) {
      _showSnack("⚠️ Failed to capture photo: $e");
      return null;
    }
  }

  Future<void> _handleAttendance() async {
    try {
      final position = await _getCurrentPosition();
      if (position == null) return;

      final photo = await _capturePhoto();
      if (photo == null) {
        _showSnack("⚠️ Could not capture photo.");
        return;
      }

      final info = NetworkInfo();
      final ipAddress = await info.getWifiIP() ?? "Unknown";

      final action = !_checkedIn ? "checkin" : "checkout";

      await _controller.checkIn(context, {
        "latitude": position.latitude,
        "longitude": position.longitude,
        "ip_address": ipAddress,
        "image_path": photo.path,
        "action": action,
      });

      setState(() {
        if (!_checkedIn) {
          _checkedIn = true;
        } else {
          _checkedOut = true;
        }
      });

      _showSnack("✅ $action successful!", success: true);
    } catch (e) {
      _showSnack("⚠️ Action failed: $e");
    }
  }

  void _showSnack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? const Color(0xFF08DA55) : Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const beeBlue = Color(0xFF1976D2);
    const beeGreen = Color(0xFF08DA55);
    const bgColor = Color(0xFFF8FAFC);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String buttonLabel;
    Color buttonColor;
    if (_checkedIn && !_checkedOut) {
      buttonLabel = "✅ Checked In\nTap to Check Out";
      buttonColor = Colors.orange;
    } else if (_checkedIn && _checkedOut) {
      buttonLabel = "🏁 Checked Out";
      buttonColor = beeGreen;
    } else {
      buttonLabel = "🕒 $_currentTime\nTap to Check In";
      buttonColor = beeBlue;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 3,
        centerTitle: true,
       
      ),
      body: Stack(
        children: [
          // 🐝 Subtle Bee Emoji Background
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.05,
                child: const Text("🐝", style: TextStyle(fontSize: 300)),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🏢 Assigned Stations
                SizedBox(
                  height: 120,
                  child: _stations.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _stations.length,
                          itemBuilder: (context, index) {
                            final station = _stations[index];
                            return Card(
                              color: Colors.white,
                              elevation: 4,
                              shadowColor: beeBlue.withOpacity(0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              margin: const EdgeInsets.only(right: 12),
                              child: Container(
                                width: 200,
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      station['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      station['address'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
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

                // 🕒 Modern Gradient Check-In Button
                GestureDetector(
                  onTap: (_checkedIn && _checkedOut) ? null : _handleAttendance,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_checkedIn ? beeGreen : beeBlue, beeGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: beeBlue.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        buttonLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
