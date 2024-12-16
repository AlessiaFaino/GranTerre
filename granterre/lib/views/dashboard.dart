import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:granterre/config.dart';
import 'package:granterre/controllers/simulation.dart';
import 'package:granterre/models/machine_data.dart';
import 'package:granterre/views/details.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  SimulatorController simulatorController = SimulatorController();

  int _machineSelected = 0;

  List<FlSpot> lineData = [];
  List<BarChartGroupData> barData = [];
  List<PieChartSectionData> pieData = [];
  List<ScatterSpot> scatterData = [];

  void loadGraphs() {

    List<MachineData> machineData = _machineSelected == 0 ? simulatorController.historyConfezionatrice : simulatorController.historyIncartonatrice;

    if (machineData.isNotEmpty) {
      lineData = machineData
          .map((data) => FlSpot(data.index.toDouble(), data.velocitaMedia.toDouble()))
          .toList();

      barData = machineData
          .map((data) => BarChartGroupData(
                x: data.index,
                barRods: [
                  BarChartRodData(
                    y: data.numeroConfezioni.toDouble(),
                    colors: [Colors.teal],
                  ),
                ],
              ))
          .toList();

      final totalConfezioni = machineData.fold<int>(
          0, (sum, data) => sum + data.numeroConfezioni);

      pieData = machineData.map((data) {
        final percentage = (data.numeroConfezioni / totalConfezioni) * 100;
        return PieChartSectionData(
          value: percentage,
          color: Colors.teal[(data.index % 9 + 1) * 100]!,
          title: '${percentage.toStringAsFixed(1)}%',
          titleStyle: const TextStyle(color: Colors.black, fontSize: 14),
          titlePositionPercentageOffset: 1.5,
        );
      }).toList();

      scatterData = machineData.map((data) {
        final colorIndex = data.status == 1 ? 400 : 600;
        return ScatterSpot(
          data.index.toDouble(),
          data.velocitaMedia.toDouble(),
          color: Colors.teal[colorIndex]!,
        );
      }).toList();
    } else {
      lineData = [];
      barData = [];
      pieData = [];
      scatterData = [];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _selectMachineDropDownButton(),
        const SizedBox(height: 40,),
        _graphs()
      ],
    );
  }

  Widget _buildChartTile(BuildContext context, String title, dynamic data, String chartType) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(
              title: title,
              data: data,
              chartType: chartType,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 8),
            Expanded(
              child: _buildMiniChart(chartType, data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChart(String chartType, dynamic data) {
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
          gridData: FlGridData(show: true, drawVerticalLine: false),
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

  Widget _selectMachineDropDownButton() {
    return DropdownButton<int>(
      icon: const Icon(
        Icons.precision_manufacturing_outlined,
        color: Colors.teal,
      ),
      value: _machineSelected,
      hint: const Text('Seleziona un macchinario'),
      items: machines.entries.map((entry) {
        return DropdownMenuItem<int>(
          value: entry.key,
          child: Text(
            entry.value,
            style: const TextStyle(
              color: Colors.teal
            ),
          ),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _machineSelected = newValue ?? 0;
        });
      },
    );
  }

  Widget _graphs() {
    return Expanded(
      child: StreamBuilder(
        stream: _machineSelected == 0 ? simulatorController.dataConfezionatriceStream : simulatorController.dataIncartonatriceStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("No data available"));
            }
            bool hasData = _machineSelected == 0 ? simulatorController.historyConfezionatrice.isNotEmpty : simulatorController.historyIncartonatrice.isNotEmpty;
            return hasData ? ListView.builder( //ListView di esempio
              itemCount: _machineSelected == 0 ? simulatorController.historyConfezionatrice.length : simulatorController.historyIncartonatrice.length,
              itemBuilder: (context, index) {
                MachineData machineData = _machineSelected == 0 ? simulatorController.historyConfezionatrice[index] : simulatorController.historyIncartonatrice[index];
                return Text(machineData.codiceRicettaRichiesta.toString()); //Text di Esempio
              }
            ) : const Center(child: Text("No data available"));
            /*return GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              mainAxisSpacing: 20.0,
              crossAxisSpacing: 20.0,
              children: [
                _buildChartTile(context, 'Line Chart', lineData, 'line'),
                _buildChartTile(context, 'Bar Chart', barData, 'bar'),
                _buildChartTile(context, 'Pie Chart', pieData, 'pie'),
                _buildChartTile(context, 'Scatter Chart', scatterData, 'scatter'),
              ],
            );*/
          },
      ),
    );
  }
}
