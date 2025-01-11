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
  List<BarChartGroupData> histogramData = [];
  List<BarChartGroupData> stackedBarData = [];
  Map<int, String> lottoLegenda = {};
  final Map<String, Map<String, int>> groupedData = {};

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
      final Map<String, Map<String, int>> groupedData = {};

    for (var data in machineData) {
      final lotto = data.lotto;
      final codiceProdotto = data.codiceProdotto;
      final numeroConfezioni = data.numeroConfezioni;

      groupedData.putIfAbsent(lotto, () => {});
      groupedData[lotto]![codiceProdotto] =
          (groupedData[lotto]![codiceProdotto] ?? 0) + numeroConfezioni;
    }

    stackedBarData = groupedData.entries.map((entry) {
      final lotto = entry.key;
      final prodotti = entry.value;

      int lottoIndex = groupedData.keys.toList().indexOf(lotto);
      lottoLegenda[lottoIndex] = lotto;

      List<BarChartRodData> rods = prodotti.entries.map((prodottoEntry) {
        final colore = Colors.teal[
            (prodotti.keys.toList().indexOf(prodottoEntry.key) % 9 + 1) * 100];
        return BarChartRodData(
          y: prodottoEntry.value.toDouble(),
          colors: [colore!],
          width: 20,
        );
      }).toList();

      return BarChartGroupData(x: lottoIndex, barRods: rods);
    }).toList();
      final histogramBuckets = <int, int>{};
      for (var data in machineData) {
        final bucket = (data.velocitaMedia ~/ 10) * 10;
        histogramBuckets[bucket] = (histogramBuckets[bucket] ?? 0) + 1;
      }

      histogramData = histogramBuckets.entries
        .map((entry) => BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              y: entry.value.toDouble(),
              colors: [Colors.teal],
              borderRadius: BorderRadius.zero,
              width: 20.0,
            ),
          ],
        ))
        .toList();
    } else {
      lineData = [];
      barData = [];
      pieData = [];
      scatterData = [];
      histogramData = [];
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
    if (chartType == 'stackedBar') {
          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30, bottom: 30),
                            child: BarChart(
                              BarChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: SideTitles(
                                    showTitles: true,
                                    getTitles: (value) => value.toInt().toString(),
                                    reservedSize: 40,
                                  ),
                                  bottomTitles: SideTitles(
                                    showTitles: true,
                                    getTitles: (value) =>
                                        lottoLegenda[value.toInt()] ?? '',
                                    reservedSize: 20,
                                  ),
                                ),
                                borderData: FlBorderData(show: true),
                                barGroups: stackedBarData,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Positioned(
                      left: 8,
                      top: 40,
                      bottom: 40,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'Numero Confezioni',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: Colors.teal),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 8,
                      left: 30,
                      right: 30,
                      child: Text(
                        'Lotto',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.teal),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
    }else if (chartType == 'histogram') {
      return Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, bottom: 30),
                  child: BarChart(
                    BarChartData(
                      
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) => value.toInt().toString(),
                          reservedSize: 40,
                        ),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) => '${value.toInt()}-${value.toInt() + 10}',
                          reservedSize: 20,
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      barGroups: data,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            left: 8,
            top: 40,
            bottom: 40,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                'Frequenza',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.teal),
              ),
            ),
          ),
          const Positioned(
            bottom: 8,
            left: 30,
            right: 30,
            child: Text(
              'Range Velocità Media',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else if (chartType == 'line') {
      return Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, bottom: 30),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) => value.toInt().toString(),
                          reservedSize: 40,
                        ),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) => value.toInt().toString(),
                          reservedSize: 20,
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      maxY: data.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10,
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: data,
                          isCurved: true,
                          colors: [Colors.teal],
                          barWidth: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            left: 8,
            top: 40,
            bottom: 40,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                'Velocità Media',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.teal),
              ),
            ),
          ),
          const Positioned(
            bottom: 8,
            left: 30,
            right: 30,
            child: Text(
              ' Indice Ciclo',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else if (chartType == 'bar') {
      return Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, bottom: 30),
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) {
                            if (value % 2000 == 0) {
                              return value.toInt().toString();
                            }
                            return '';
                          },
                          reservedSize: 40,
                        ),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) {
                          final index = value.toInt();
                          if (_machineSelected == 0) {
                            if (index < simulatorController.historyConfezionatrice.length) {
                              return simulatorController.historyConfezionatrice[index].codiceProdotto;
                            }
                          } else {
                            if (index < simulatorController.historyIncartonatrice.length) {
                              return simulatorController.historyIncartonatrice[index].codiceProdotto;
                            }
                          }
                          return '';
                          },
                          reservedSize: 20,
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      barGroups: data,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            left: 8,
            top: 40,
            bottom: 40,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                'Quantità',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.teal),
              ),
            ),
          ),
          const Positioned(
            bottom: 8,
            left: 30,
            right: 30,
            child: Text(
              'Codice Prodotto',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else if (chartType == 'pie') {
      return PieChart(
        PieChartData(sections: data),
      );
    } else {
      return Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, bottom: 30),
                  child: ScatterChart(
                    ScatterChartData(
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      scatterSpots: data,
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) => value.toInt().toString(),
                          reservedSize: 40,
                        ),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) => value.toInt().toString(),
                          reservedSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            left: 8,
            top: 40,
            bottom: 40,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                'Velocità Media',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.teal),
              ),
            ),
          ),
          const Positioned(
            bottom: 8,
            left: 30,
            right: 30,
            child: Text(
              'Indice Ciclo',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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

    final isMobile = MediaQuery.of(context).size.width < 1200;

    return Expanded(
      child: StreamBuilder(
        stream: _machineSelected == 0
            ? simulatorController.dataConfezionatriceStream
            : simulatorController.dataIncartonatriceStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                children: [
                  Text("Attendo che la simulazione venga lanciata...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 16,),
                  CircularProgressIndicator(),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          /*if (!snapshot.hasData) {
            return const Center(child: Text("No data available"));
          }*/

          loadGraphs();

          bool hasData = _machineSelected == 0
              ? simulatorController.historyConfezionatrice.isNotEmpty
              : simulatorController.historyIncartonatrice.isNotEmpty;

          if (!hasData) {
            return const Center(child: Text("No data available"));
          }

          return GridView.count(
            crossAxisCount: isMobile ? 1 : 2, 
            padding: const EdgeInsets.all(16.0),
            mainAxisSpacing: 20.0,
            crossAxisSpacing: 20.0,
            children: [
              _buildChartTile(context, 'Variazione della Velocità Media nel Tempo', lineData, 'line'),
              _buildChartTile(context, 'Numero di Confezioni Prodotte per Codice Prodotto', barData, 'bar'),
              //_buildChartTile(context, 'Distribuzione Percentuale della Produzione', pieData, 'pie'),
              _buildChartTile(context, 'Velocità Media per Ciclo', scatterData, 'scatter'),
              _buildChartTile(context, 'Distribuzione Velocità Media', histogramData, 'histogram'),
              _buildChartTile(context, 'Composizione Produttiva per Lotto', stackedBarData, 'stackedBar'),
            ],
          );
        },
      ),
    );
  }
}