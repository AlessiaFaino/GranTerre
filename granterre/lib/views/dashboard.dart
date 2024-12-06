import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenScreenState();
}

class _DashboardScreenScreenState extends State<DashboardScreen> {
  Map<int, int> frequency = {
    1:500,
    2:200,
    3:300,
    4:100
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final sortedKeys = frequency.keys.toList()..sort();
    List<BarChartGroupData> barGroups = sortedKeys.map((key) {
      return BarChartGroupData(
        x: key,
        barRods: [
          BarChartRodData(
            y: frequency[key]?.toDouble() ?? 0.0,
            colors: [Colors.blue],  // Usa 'colors' invece di 'color'
            width: 15,
          )
        ],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizzazione Dati'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: frequency.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitles: (value) => value.toInt().toString(),
                    ),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) => '${value.toInt()}-${value.toInt() + 9}',
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
      ),
    );
  }
}
