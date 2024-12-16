import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DetailsScreen extends StatelessWidget {
  final String title;
  final dynamic data;
  final String chartType;

  const DetailsScreen({
    super.key,
    required this.title,
    required this.data,
    required this.chartType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.teal, // Impostato il colore teal
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _buildChart(chartType, data),
            ),
            // Etichette forzate
            if (chartType == 'line' || chartType == 'bar' || chartType == 'scatter') ...[
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Velocity', style: TextStyle(fontSize: 14, color: Colors.teal)),
                  Text('Index', style: TextStyle(fontSize: 14, color: Colors.teal)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('A chart representing the relationship between index and velocity/quantity.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
            if (chartType == 'pie') ...[
              const SizedBox(height: 20),
              const Text('A chart representing the proportion of items per section.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart(String chartType, dynamic data) {
    if (chartType == 'line') {
      return LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: true),
            bottomTitles: SideTitles(showTitles: true),
          ),
          borderData: FlBorderData(show: true),
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: data,
              isCurved: true,
              colors: [Colors.teal],
              barWidth: 3,
            ),
          ],
        ),
      );
    } else if (chartType == 'bar') {
      return BarChart(
        BarChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: true,
              getTitles: (value) {
                return value.toInt().toString();  // Personalizza l'asse Y
              },
            ),
            bottomTitles: SideTitles(showTitles: true),
          ),
          borderData: FlBorderData(show: true),
          barGroups: data,
        ),
      );
    } else if (chartType == 'pie') {
      return PieChart(
        PieChartData(sections: data),
      );
    } else {
      return ScatterChart(
        ScatterChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(leftTitles: SideTitles(showTitles: true), bottomTitles: SideTitles(showTitles: true)),
          borderData: FlBorderData(show: true),
          scatterSpots: data,
        ),
      );
    }
  }
}
