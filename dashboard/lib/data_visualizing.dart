import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for TextInputFormatter

class SensorDataScreen extends StatefulWidget {
  const SensorDataScreen({super.key});

  @override
  State<SensorDataScreen> createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  late DatabaseReference _refCurrent;
  late DatabaseReference _refVoltage;
  late DatabaseReference _refHumidity;
  late DatabaseReference _refSpeed;
  late DatabaseReference _refTemp;

  dynamic current = 0;
  dynamic voltage = 0;
  dynamic humidity = 0;
  dynamic speed = 0;
  dynamic temp = 0;

  @override
  void initState() {
    super.initState();
    // Set up Firebase Realtime Database listeners
    _refCurrent = FirebaseDatabase.instance.reference().child("sensors/current");
    _refCurrent.onValue.listen((event) {
      setState(() {
        current = event.snapshot.value as dynamic;
      });
    });

    _refVoltage = FirebaseDatabase.instance.reference().child("sensors/voltage");
    _refVoltage.onValue.listen((event) {
      setState(() {
        voltage = event.snapshot.value as dynamic;
      });
    });

    _refHumidity = FirebaseDatabase.instance.reference().child("dht/humidity");
    _refHumidity.onValue.listen((event) {
      setState(() {
        humidity = event.snapshot.value as dynamic;
      });
    });

    _refSpeed = FirebaseDatabase.instance.reference().child("sensors/speed");
    _refSpeed.onValue.listen((event) {
      setState(() {
        speed = event.snapshot.value as dynamic;
      });
    });

    _refTemp = FirebaseDatabase.instance.reference().child("dht/temp");
    _refTemp.onValue.listen((event) {
      setState(() {
        temp = event.snapshot.value as dynamic;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sensor Data Visualizing"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey, // Changed app bar color
        iconTheme: const IconThemeData(color: Colors.white), // Changed icon color
      ),
      backgroundColor: Colors.lightBlueAccent, // Changed background color
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Temperature Circular Progress Indicator
              _buildCircularProgressIndicator(
                label: "Temperature",
                value: temp.toDouble(),
                maxValue: 100, // Max temperature value (example, adjust based on range)
                unit: "°C",
              ),
              const SizedBox(height: 30),

              // Current Circular Progress Indicator
              _buildCircularProgressIndicator(
                label: "Current",
                value: current.toDouble(),
                maxValue: 100, // Max current value (adjust based on expected range)
                unit: "A",
              ),
              const SizedBox(height: 30),

              // Voltage Circular Progress Indicator
              _buildCircularProgressIndicator(
                label: "Voltage",
                value: voltage.toDouble(),
                maxValue: 500, // Max voltage value (example, adjust based on range)
                unit: "V",
              ),
              const SizedBox(height: 30),

              // Humidity Circular Progress Indicator
              _buildCircularProgressIndicator(
                label: "Humidity",
                value: humidity.toDouble(),
                maxValue: 100, // Max humidity value (percentage)
                unit: "%",
              ),
              const SizedBox(height: 30),

              // Speed Circular Progress Indicator
              _buildCircularProgressIndicator(
                label: "Speed",
                value: speed.toDouble(),
                maxValue: 200, // Max speed value (example, adjust based on range)
                unit: "m/s",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Circular Progress Indicator widget
  Widget _buildCircularProgressIndicator({
    required String label,
    required double value,
    required double maxValue,
    required String unit,
  }) {
    // Calculate the normalized value (0 to 1)
    double normalizedValue = value / maxValue;

    // Determine the color based on the value
    Color progressColor = _getProgressColor(normalizedValue);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          value: normalizedValue, // Normalize the value between 0 and 1
          strokeWidth: 8.0,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
        const SizedBox(height: 10),
        Text(
          "$label: ${value.toStringAsFixed(2)} $unit",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white), // Text color changed to white
        ),
      ],
    );
  }

  // Function to determine progress color
  Color _getProgressColor(double normalizedValue) {
    if (normalizedValue < 0.33) {
      return Colors.green; // Low value
    } else if (normalizedValue < 0.66) {
      return Colors.orange; // Medium value
    } else {
      return Colors.red; // High value
    }
  }
}
