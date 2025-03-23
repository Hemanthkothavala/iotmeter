import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart'; // Directly load Dashboard

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes debug banner
      title: 'IoT Smart Meter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DashboardScreen(), // Launches Dashboard directly
    );
  }
}
