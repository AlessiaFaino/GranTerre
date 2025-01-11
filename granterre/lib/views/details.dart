import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:granterre/controllers/simulation.dart';
import 'package:granterre/models/machine_data.dart';
import 'package:granterre/config.dart';

class DetailsScreen extends StatefulWidget {
  final String title;
  final String chartType;

  const DetailsScreen({
    required this.title,
    required this.chartType,
    super.key,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  SimulatorController simulatorController = SimulatorController();

  List<FlSpot> lineData = [];
  List<BarChartGroupData> barData = [];
  List<PieChartSectionData> pieData = [];
  List<ScatterSpot> scatterData = [];
  List<BarChartGroupData> histogramData = [];
  List<BarChartGroupData> stackedBarData = [];
  Map<int, String> lottoLegenda = {};
  final Map<String, Map<String, int>> groupedData = {};

  int _machineSelected = 0;

  void loadGraphs(int machineType) {
    List<MachineData> machineData = machineType == 0
        ? simulatorController.historyConfezionatrice
        : simulatorController.historyIncartonatrice;

    if (machineData.isNotEmpty) {
      lineData = machineData
          .map((data) => FlSpot(data.index.toDouble(), data.velocitaMedia.toDouble()))
          .toList();

      barData = machineData
          .asMap()
          .entries
          .map((entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    y: entry.value.numeroConfezioni.toDouble(),
                    colors: [Colors.teal],
                  ),
                ],
              ))
          .toList();

      final totalConfezioni = machineData.fold<int>(0, (sum, data) => sum + data.numeroConfezioni);

      pieData = machineData.asMap().entries.map((entry) {
        final percentage = (entry.value.numeroConfezioni / totalConfezioni) * 100;
        return PieChartSectionData(
          value: percentage,
          color: Colors.teal[(entry.key % 9 + 1) * 100]!,
          title: '${percentage.toStringAsFixed(1)}%',
          titleStyle: const TextStyle(color: Colors.black, fontSize: 14),
          titlePositionPercentageOffset: 1.5,
        );
      }).toList();

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

      scatterData = machineData.map((data) {
        final colorIndex = data.status == 1 ? 400 : 600;
        return ScatterSpot(
          data.index.toDouble(),
          data.velocitaMedia.toDouble(),
          color: Colors.teal[colorIndex]!,
        );
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
                    width: 20.0,
                    borderRadius: BorderRadius.zero, 
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
    loadGraphs(_machineSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(
          color: Colors.white
          ),
          title: Text(widget.title, style: const TextStyle(
          color: Colors.white
          )),
          backgroundColor: Colors.teal,
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _selectMachineDropDownButton(),
            const SizedBox(height: 20),
            _buildChart(),
          ],
        ),
      ),
    );
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
            style: const TextStyle(color: Colors.teal),
          ),
        );
      }).toList(),
      onChanged: (int? newValue) {
        if (newValue != null) {
          setState(() {
            _machineSelected = newValue;
            loadGraphs(_machineSelected); 
          });
        }
      },
    );
  }

Widget _buildChart() {
  return Expanded(
    child: StreamBuilder(
      stream: _machineSelected == 0
          ? simulatorController.dataConfezionatriceStream
          : simulatorController.dataIncartonatriceStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && lineData.isEmpty) {
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

        loadGraphs(_machineSelected);

        if (widget.chartType == 'stackedBar') {
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
        }else if (widget.chartType == 'line') {
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
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: SideTitles(
                                    showTitles: true,
                                    getTitles: (value) =>
                                        value % 10 == 0 ? value.toInt().toString() : '',
                                    reservedSize: 28,
                                    interval: 10,
                                  ),
                                  bottomTitles: SideTitles(
                                    showTitles: true,
                                    getTitles: (value) =>
                                        value % 2 == 0 ? value.toInt().toString() : '',
                                    reservedSize: 28,
                                    interval: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: true),
                                maxY: lineData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10,
                                minY: 0,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: lineData,
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
                        'Indice Ciclo',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.teal),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Questo grafico a linee mostra l andamento della velocità media della macchina nel tempo. Evidenziando la variazione di velocità e i cali/picchi di performance.',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        }else if (widget.chartType == 'bar') {
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
                                gridData: FlGridData(show: true, drawVerticalLine: false),
                                titlesData: FlTitlesData(
                                  leftTitles: SideTitles(
                                    showTitles: true,
                                    getTitles: (value) =>
                                        value % 2000 == 0 ? value.toInt().toString() : '',
                                    reservedSize: 28,
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
                                    reservedSize: 28,
                                  ),
                                ),
                                borderData: FlBorderData(show: true),
                                barGroups: barData,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Positioned(
                      left: 2,
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
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Questo grafico a barre rappresenta i valori discreti di diverse categorie. Ogni barra illustra il numero di confezioni prodotte dalla macchina per ogni ciclo o unità di tempo.',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        }else if (widget.chartType == 'scatter') {
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
                            child: ScatterChart(
                              ScatterChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(
                                  leftTitles: SideTitles(
                                    showTitles: true,
                                    getTitles: (value) => value.toInt().toString(), 
                                    reservedSize: 28,
                                    interval: 1, 
                                  ),
                                  bottomTitles: SideTitles(
                                    showTitles: true,
                                    getTitles: (value) => value.toInt().toString(), 
                                    reservedSize: 28,
                                    interval: 1, 
                                  ),
                                ),
                                borderData: FlBorderData(show: true),
                                scatterSpots: scatterData,
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
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Questo grafico a dispersione rappresenta la velocità media della macchina rispetto ai cicli. Ogni punto evidenzia un ciclo specifico e la velocità corrispondente, indicanto in base alla colorazione eventuali problematiche in fase di produzione',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
          }else if (widget.chartType == 'pie') {
            return Column(
              children: [
                Expanded(
                  flex: 4,
                  child: PieChart(
                    PieChartData(
                      sections: pieData,
                      sectionsSpace: 4,
                      centerSpaceRadius: 90,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Legenda:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  flex: 1,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, 
                      crossAxisSpacing: 8.0, 
                      mainAxisSpacing: 50.0, //n.b  x max regola la legenda 50 è voluto
                      childAspectRatio: 3, 
                    ),
                    itemCount: _machineSelected == 0
                        ? simulatorController.historyConfezionatrice.length
                        : simulatorController.historyIncartonatrice.length,
                    itemBuilder: (context, index) {
                      final machineData = _machineSelected == 0
                          ? simulatorController.historyConfezionatrice[index]
                          : simulatorController.historyIncartonatrice[index];
                      return Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: Colors.teal[(index % 9 + 1) * 100],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Ordine: ${machineData.ordineDiLavoro}',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Questo grafico a torta mostra la distribuzione percentuale di ciascun ordine di lavoro rispetto alla produzione totale.',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }else if (widget.chartType == 'histogram') {
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
                            barGroups: histogramData,
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
          }

          return const Center(child: Text("Unsupported chart type"));
        },
      ),
    );
  }
}