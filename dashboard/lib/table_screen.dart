import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  _TablesScreenState createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  List<Map<String, dynamic>> _sensorData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
  }

  Future<void> _fetchSensorData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sensors') // Firestore collection name
          .get();

      final data = snapshot.docs.map((doc) {
        final timestamp = doc.id; // Use document ID as the timestamp
        final sensorData = doc.data();
        return {
          'timestamp': timestamp,
          'temperature': sensorData['temp'] ?? 'N/A',
          'humidity': sensorData['humidity'] ?? 'N/A',
          'voltage': sensorData['voltage'] ?? 'N/A',
          'current': sensorData['current'] ?? 'N/A',
          'speed': sensorData['speed'] ?? 'N/A',
        };
      }).toList();

      setState(() {
        _sensorData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey, // Changed background color
      appBar: AppBar(
        title: const Text('Sensor Data Table'),
        backgroundColor: Colors.deepPurple, // Changed AppBar color
        iconTheme: const IconThemeData(color: Colors.white), // Changed icon color
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20.0, // Increased space between columns
            columns: const [
              DataColumn(label: Text('Timestamp')),
              DataColumn(label: Text('Temperature (°C)')),
              DataColumn(label: Text('Humidity (%)')),
              DataColumn(label: Text('Voltage (V)')),
              DataColumn(label: Text('Current (A)')),
              DataColumn(label: Text('Speed (m/s)')),
            ],
            rows: _sensorData.map((data) {
              return DataRow(
                cells: [
                  DataCell(Text(
                    data['timestamp'],
                    style: const TextStyle(color: Colors.white), // Changed text color
                  )),
                  DataCell(Text(
                    data['temperature'].toString(),
                    style: const TextStyle(color: Colors.white), // Changed text color
                  )),
                  DataCell(Text(
                    data['humidity'].toString(),
                    style: const TextStyle(color: Colors.white), // Changed text color
                  )),
                  DataCell(Text(
                    data['voltage'].toString(),
                    style: const TextStyle(color: Colors.white), // Changed text color
                  )),
                  DataCell(Text(
                    data['current'].toString(),
                    style: const TextStyle(color: Colors.white), // Changed text color
                  )),
                  DataCell(Text(
                    data['speed'].toString(),
                    style: const TextStyle(color: Colors.white), // Changed text color
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
