import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorScatterPlotPage extends StatefulWidget {
  const SensorScatterPlotPage({super.key});

  @override
  State<SensorScatterPlotPage> createState() => _SensorScatterPlotPageState();
}

class _SensorScatterPlotPageState extends State<SensorScatterPlotPage> {
  List<ScatterSpot> _tempPoints = [];
  List<ScatterSpot> _humidityPoints = [];
  List<ScatterSpot> _speedPoints = [];
  List<ScatterSpot> _voltagePoints = [];
  List<ScatterSpot> _currentPoints = [];
  List<ScatterSpot> _tempVoltagePoints = [];
  List<ScatterSpot> _tempCurrentPoints = [];
  List<ScatterSpot> _airDensityPoints = [];

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
  }

  Future<void> _fetchSensorData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sensors') // Collection name
          .get();

      List<ScatterSpot> tempPoints = [];
      List<ScatterSpot> humidityPoints = [];
      List<ScatterSpot> speedPoints = [];
      List<ScatterSpot> voltagePoints = [];
      List<ScatterSpot> currentPoints = [];
      List<ScatterSpot> tempVoltagePoints = [];
      List<ScatterSpot> tempCurrentPoints = [];
      List<ScatterSpot> airDensityPoints = [];

      snapshot.docs.forEach((doc) {
        final timestamp =
            double.tryParse(doc.id) ?? 0; // Parse the doc ID as a timestamp
        final data = doc.data();

        final temp = data['temp'] as double;
        final voltage = (data['voltage'] as num).toDouble();
        final current = (data['current'] as num).toDouble();

        // Calculate air density using the given formula: p = 101325 / (287 * (temp + 273.15))
        final airDensity = 101325 / (287 * (temp + 273.15));

        tempPoints.add(ScatterSpot(timestamp, temp));
        humidityPoints.add(ScatterSpot(timestamp, (data['humidity'] as num).toDouble()));
        speedPoints.add(ScatterSpot(timestamp, (data['speed'] as num).toDouble()));
        voltagePoints.add(ScatterSpot(timestamp, voltage));
        currentPoints.add(ScatterSpot(timestamp, current));

        tempVoltagePoints.add(ScatterSpot(temp, voltage));
        tempCurrentPoints.add(ScatterSpot(temp, current));
        airDensityPoints.add(ScatterSpot(timestamp, airDensity));
      });

      setState(() {
        _tempPoints = tempPoints;
        _humidityPoints = humidityPoints;
        _speedPoints = speedPoints;
        _voltagePoints = voltagePoints;
        _currentPoints = currentPoints;
        _tempVoltagePoints = tempVoltagePoints;
        _tempCurrentPoints = tempCurrentPoints;
        _airDensityPoints = airDensityPoints;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        title: const Text('Sensor Readings Scatter Plot'),
        backgroundColor: Colors.deepPurple, // Updated AppBar color
        actions: [
          IconButton(
            icon: Icon(Icons.refresh), // Refresh Icon
            onPressed: _fetchSensorData,
          ),
        ],
      ),
      body: _tempPoints.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.indigo, // Solid background color (indigo)
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Temperature',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                _buildScatterPlot(_tempPoints, Colors.tealAccent, '°C'),
                const SizedBox(height: 20),
                const Text(
                  'Humidity',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                _buildScatterPlot(_humidityPoints, Colors.blueAccent, '%'),
                const SizedBox(height: 20),
                const Text(
                  'Speed',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                _buildScatterPlot(_speedPoints, Colors.orangeAccent, 'm/s'),
                const SizedBox(height: 20),
                const Text(
                  'Voltage',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                _buildScatterPlot(_voltagePoints, Colors.purpleAccent, 'V'),
                const SizedBox(height: 20),
                const Text(
                  'Current',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                _buildScatterPlot(_currentPoints, Colors.greenAccent, 'A'),
                const SizedBox(height: 20),
                const Text(
                  'Temperature vs Voltage',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                _buildScatterPlot(_tempVoltagePoints, Colors.redAccent, 'V'),
                const SizedBox(height: 20),
                const Text(
                  'Temperature vs Current',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                _buildScatterPlot(_tempCurrentPoints, Colors.yellowAccent, 'A'),
                const SizedBox(height: 20),
                const Text(
                  'Air Density',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                _buildScatterPlot(_airDensityPoints, Colors.cyanAccent, 'kg/m³'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScatterPlot(List<ScatterSpot> points, Color color, String unit) {
    return SizedBox(
      height: 250,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: points,
          scatterTouchData: ScatterTouchData(
            enabled: true,
            touchTooltipData: ScatterTouchTooltipData(
              tooltipBgColor: Colors.black.withOpacity(0.7),
            ),
          ),
          gridData: FlGridData(show: true, drawHorizontalLine: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  value.toString(), // Display value directly
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  value.toStringAsFixed(1) + unit,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: Colors.white),
              bottom: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
