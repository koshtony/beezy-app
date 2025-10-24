import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const HRApp());
}

class HRApp extends StatelessWidget {
  const HRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "HR Management",
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
