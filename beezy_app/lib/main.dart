import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/approval_controller.dart';
import 'controllers/leave_controller.dart';
import 'pages/login_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApprovalController()),
        ChangeNotifierProvider(create: (_) => LeaveController()),
      ],
      child: const HRApp(),
    ),
  );
}

class HRApp extends StatelessWidget {
  const HRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "HR Management",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
