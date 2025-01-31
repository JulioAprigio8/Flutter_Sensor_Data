import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Data Chart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SensorDataChart(),
    );
  }
}

class SensorDataChart extends StatefulWidget {
  const SensorDataChart({super.key});

  @override
  State<SensorDataChart> createState() => _SensorDataChartState();
}

class _SensorDataChartState extends State<SensorDataChart> {
  List<FlSpot> temperatureData = [];
  List<FlSpot> humidityData = [];
  Timer? timer;
  int x = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer t) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.26'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperatureData.add(FlSpot(x.toDouble(), data['temperature']));
          humidityData.add(FlSpot(x.toDouble(), data['humidity']));
          x++;
          if (temperatureData.length > 20) {
            temperatureData.removeAt(0);
            humidityData.removeAt(0);
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Data Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minX: x > 20 ? (x - 20).toDouble() : 0,
            maxX: x.toDouble(),
            minY: 0,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: temperatureData,
          isCurved: true,
                color: Colors.red,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: humidityData,
                isCurved: true,
                color: Colors.blue,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Color(0xff37434d),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Color(0xff37434d),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: Color(0xff67727d),
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d), width: 1),
            ),
          ),
        ),
      ),
    );
  }
}
