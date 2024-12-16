import 'package:flutter/material.dart';
import 'package:granterre/config.dart';
import 'package:granterre/controllers/simulation.dart';
import 'package:granterre/utils.dart';

class AppFAB extends StatefulWidget {

  const AppFAB({
    super.key,
  });

  @override
  State<AppFAB> createState() => _AppFABState();
}

class _AppFABState extends State<AppFAB> {

  SimulatorController simulatorController = SimulatorController();

  void _toggleConfezionatriceSimulation() {
    setState(() {
      simulationConfezionatriceOn = !simulationConfezionatriceOn;
      simulationConfezionatriceOn ? simulatorController.startFetchingData(context, 0) : simulatorController.pauseFetchingData(context, 0);
    });
    AppUtils.showSnackBar(context, "Simulazione ${simulationConfezionatriceOn ? "avviata" : "interrotta"} con successo!", false);
  }

  void _toggleIncartonatriceSimulation() {
    setState(() {
      simulationIncartonatriceOn = !simulationIncartonatriceOn;
      simulationIncartonatriceOn ? simulatorController.startFetchingData(context, 1) : simulatorController.pauseFetchingData(context, 1);
    });
    AppUtils.showSnackBar(context, "Simulazione ${simulationIncartonatriceOn ? "avviata" : "interrotta"} con successo!", false);
  }

  @override
  Widget build(BuildContext context) {  
    return Stack(
      children: [
        Positioned(
          bottom: 80,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: "fab_confezionatrice",
            label: Text("Simulazione Confezionatrice ${simulationConfezionatriceOn ? "in corso" : "in pausa"}"),
            tooltip: "${simulationConfezionatriceOn ? "Interrompi" : "Avvia"} simulazione",
            onPressed: _toggleConfezionatriceSimulation,
            backgroundColor: simulationConfezionatriceOn ? Colors.teal : Colors.red,
            foregroundColor: Colors.white,
            icon: simulationConfezionatriceOn ? const Icon(
              Icons.pause_rounded
            ) : const Icon(
              Icons.play_arrow_rounded
            )
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: "fab_incartonatrice",
            label: Text("Simulazione Incartonatrice ${simulationIncartonatriceOn ? "in corso" : "in pausa"}"),
            tooltip: "${simulationIncartonatriceOn ? "Interrompi" : "Avvia"} simulazione",
            onPressed: _toggleIncartonatriceSimulation,
            backgroundColor: simulationIncartonatriceOn ? Colors.teal : Colors.red,
            foregroundColor: Colors.white,
            icon: simulationIncartonatriceOn ? const Icon(
              Icons.pause_rounded
            ) : const Icon(
              Icons.play_arrow_rounded
            )
          ),
        ),
      ],
    );
  }
}

