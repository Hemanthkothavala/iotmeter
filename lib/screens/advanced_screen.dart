import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdvancedScreen extends StatefulWidget {
  const AdvancedScreen({super.key});

  @override
  _AdvancedScreenState createState() => _AdvancedScreenState();
}

class _AdvancedScreenState extends State<AdvancedScreen> {
  double _voltage0 = 0.0, _current0 = 0.0, _power0 = 0.0;
  double _voltage1 = 0.0, _current1 = 0.0, _power1 = 0.0;
  late Timer _timer;

  final String _firebaseUrl =
      'https://iot-meter-3b2c6-default-rtdb.firebaseio.com';
  final String _secret = 'B33rDy4fiFU6x1EEWrmf2uPHD53j7VTKoiC9U8n6';

  @override
  void initState() {
    super.initState();
    _fetchLatestData();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchLatestData();
    });
  }

  double _extractNumericValue(dynamic value) {
    if (value == null) return 0.0;
    try {
      final numericString = value.toString().replaceAll(RegExp(r'[^0-9.]'), '');
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
          setState(() {
            _voltage0 = _extractNumericValue(data['meter0']?['voltage']);
            _current0 = _extractNumericValue(data['meter0']?['current']);
            _power0 = _extractNumericValue(data['meter0']?['power']);

            _voltage1 = _extractNumericValue(data['meter1']?['voltage']);
            _current1 = _extractNumericValue(data['meter1']?['current']);
            _power1 = _extractNumericValue(data['meter1']?['power']);
          });
        }
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Failed to fetch data: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Advanced Meter Readings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isLandscape = constraints.maxWidth > 600;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Live Electrical Parameters',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  isLandscape
                      ? Row(
                          children: [
                            Expanded(child: _buildMeterCard('Meter 1', _voltage0, _current0, _power0)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildMeterCard('Meter 2', _voltage1, _current1, _power1)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildMeterCard('Meter 1', _voltage0, _current0, _power0),
                            const SizedBox(height: 20),
                            _buildMeterCard('Meter 2', _voltage1, _current1, _power1),
                          ],
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Creates a professional card for each meter
  Widget _buildMeterCard(String title, double voltage, double current, double power) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(thickness: 1, color: Colors.black26),
            const SizedBox(height: 10),

            _buildMetricRow('Voltage', '${voltage.toStringAsFixed(2)} V', Colors.orange),
            const SizedBox(height: 15),
            _buildMetricRow('Current', '${current.toStringAsFixed(2)} A', Colors.blue),
            const SizedBox(height: 15),
            _buildMetricRow('Power', '${power.toStringAsFixed(2)} W', Colors.green),
          ],
        ),
      ),
    );
  }

  // Creates a stylish metric row
  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
