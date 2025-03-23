import 'package:flutter/material.dart';

class PowerLimitScreen extends StatefulWidget {
  const PowerLimitScreen({super.key});

  @override
  _PowerLimitScreenState createState() => _PowerLimitScreenState();
}

class _PowerLimitScreenState extends State<PowerLimitScreen> {
  double _limit = 100.0;

  void _updateLimit(double value) {
    setState(() {
      _limit = value;
    });
    // Send updated limit to your IoT backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Power Limit')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Current Limit: $_limit kWh',
              style: const TextStyle(fontSize: 20)),
          Slider(
            min: 10,
            max: 500,
            value: _limit,
            onChanged: _updateLimit,
          ),
        ],
      ),
    );
  }
}
