import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'advanced_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  double _energyConsumption0 = 0.0;
  bool _deviceOnline = false;
  String _theftStatus = "Checking...";
  String _currentTime = "";
  late Timer _timer;
  late Timer _clockTimer;
  DateTime _lastUpdateTime = DateTime.now();
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  final String _firebaseUrl =
      'https://iot-meter-3b2c6-default-rtdb.firebaseio.com';
  final String _secret = 'B33rDy4fiFU6x1EEWrmf2uPHD53j7VTKoiC9U8n6';

  @override
  void initState() {
    super.initState();
    _fetchLatestData();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchLatestData();
    });

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  void _updateTime() {
    setState(() {
      _currentTime = _formatTime(DateTime.now());
    });
  }

  String _formatTime(DateTime time) {
    String hour = (time.hour % 12 == 0 ? 12 : time.hour % 12).toString();
    String minute = time.minute.toString().padLeft(2, '0');
    String second = time.second.toString().padLeft(2, '0');
    String period = time.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute:$second $period";
  }

  double _extractNumericValue(dynamic value) {
    if (value == null) return 0.0;
    try {
      final numericString = value.toString().replaceAll(
        RegExp(r'[^0-9.-]'),
        '',
      );
      return double.tryParse(numericString) ?? 0.0;
    } catch (e) {
      print("Error parsing value: $value");
      return 0.0;
    }
  }

  Future<void> _fetchLatestData() async {
    final url = Uri.parse('$_firebaseUrl/.json?auth=$_secret');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          double meter0 = _extractNumericValue(data['meter0']?['power']);

          setState(() {
            if (meter0 != _energyConsumption0) {
              _lastUpdateTime = DateTime.now();
              _deviceOnline = true;
              _energyConsumption0 = meter0;
              _theftStatus =
                  meter0 > 100 ? "❌ Theft Detected" : "✅ No Theft Detected";
            }
          });
        }
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Failed to fetch data: $e");
    }

    // Check if data is outdated
    if (DateTime.now().difference(_lastUpdateTime).inSeconds > 60) {
      setState(() {
        _deviceOnline = false; // Mark as Offline if no updates for 10 seconds
        _theftStatus = "⚠️ Unable to Determine";
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _clockTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Dashboard'),
            Text(
              _currentTime,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'IoT Smart Meter',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              _buildAnimatedCard(
                title: 'Power Consumption',
                value: '${_energyConsumption0.toStringAsFixed(2)} W',
                icon: Icons.electrical_services,
                color: Colors.orangeAccent,
                delay: 300,
              ),

              const SizedBox(height: 20),

              _buildAnimatedCard(
                title: 'Theft Status',
                value: _deviceOnline == null ? '⚠️ Unable to Determine' : _theftStatus,
                icon: Icons.warning_amber,
                color:
                    _theftStatus.contains('❌')
                        ? Colors.redAccent
                        : Colors.green,
                delay: 500,
              ),

              const SizedBox(height: 20),

              _buildAnimatedCard(
                title: 'Connectivity Status',
                value: _deviceOnline ? '✅ Online' : '❌ Offline',
                icon: _deviceOnline ? Icons.wifi : Icons.wifi_off,
                color: _deviceOnline ? Colors.green : Colors.red,
                delay: 700,
              ),

              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                const AdvancedScreen(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0), // Slide from right
                              end: Offset.zero,
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  child: const Text(
                    'Advanced →',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: delay),
      tween: Tween<double>(begin: -30, end: 0),
      builder: (context, double offset, child) {
        return Transform.translate(
          offset: Offset(0, offset),
          child: AnimatedOpacity(
            opacity: offset == 0 ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: child,
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 40, color: color),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
