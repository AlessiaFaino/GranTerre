import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:granterre/components/description.dart';
import 'package:granterre/components/header.dart';
import 'package:granterre/components/title.dart';
import 'package:granterre/config.dart';
import 'package:granterre/utils.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {

  final TextEditingController _secondsIntervalConfezionatriceController = TextEditingController();
  final TextEditingController _secondsIntervalIncartonatriceController = TextEditingController();

  @override
  void initState() {
    _secondsIntervalConfezionatriceController.text = secondsIntervalConfezionatrice.toString();
    _secondsIntervalIncartonatriceController.text = secondsIntervalIncartonatrice.toString();
    super.initState();
  }

  void _updateSecondsInterval() {
    setState(() {
      secondsIntervalConfezionatrice = int.tryParse(_secondsIntervalConfezionatriceController.text) ?? 60;
      secondsIntervalIncartonatrice = int.tryParse(_secondsIntervalIncartonatriceController.text) ?? 60;
    });
    AppUtils.showSnackBar(context, "Intervalli aggiornati correttamente", false);
  }

  void _resetSimulation() {
    if (simulationConfezionatriceOn || simulationIncartonatriceOn) {
      AppUtils.showSnackBar(context, "Impossibile eseguire il reset della simulazione mentre è in corso. Interrompere prima la simulazione dei due macchinari", true);
    } else {
      AppUtils.showConfirmationDialog(context, "Sei sicuro di voler eseguire il reset della simulazione?", "Tutti i dati caricati finora saranno eliminati", () {
        setState(() {
          //TODO: reset simulation
        });
      AppUtils.showSnackBar(context, "Simulazione reimpostata con successo!", false);
      }, isConfirmDefault: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppTitle(text: "Simulazione"),
            const SizedBox(height: 10,),
            const AppHeader(big: true, text: "Configurazione Ambiente"),
            const SizedBox(height: 10,),
            const AppDescription(
              text: "L'utente può simulare il caricamento dei valori in tempo reale da parte dei macchinari, impostando l'intervallo di tempo (stabilito in secondi) con cui i macchinari inviano dati al sistema"
            ),
            const SizedBox(height: 40,),
            _secondsIntervalConfezionatriceField(),
            const SizedBox(height: 16,),
            _secondsIntervalIncartonatriceField(),
            const SizedBox(height: 20,),
            _saveButton(),
            const SizedBox(height: 40,),
            const AppHeader(big: true, text: "Reset Ambiente"),
            const SizedBox(height: 10,),
            const AppDescription(
              text: "Prima avviare la simulazione, è bene reimpostare i dati da zero."
            ),
            const SizedBox(height: 20,),
            _resetButton()
          ],
        ),
      ),
    );
  }

  Widget _secondsIntervalConfezionatriceField() {
    return TextField(
      controller: _secondsIntervalConfezionatriceController,
      keyboardType: const TextInputType.numberWithOptions(),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      autocorrect: false,
      decoration: const InputDecoration(
        constraints: BoxConstraints(
          minWidth: 400,
          maxWidth: 400,
        ),
        hintText: "60",
        labelText: "Intervallo Confezionatrice (secondi)",
        floatingLabelStyle: TextStyle(
          color: Colors.teal
        ),
        icon: Icon(Icons.timer),
        iconColor: Colors.teal,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
      )
    );
  }

  Widget _secondsIntervalIncartonatriceField() {
    return TextField(
      controller: _secondsIntervalIncartonatriceController,
      keyboardType: const TextInputType.numberWithOptions(),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      autocorrect: false,
      decoration: const InputDecoration(
        constraints: BoxConstraints(
          minWidth: 400,
          maxWidth: 400,
        ),
        hintText: "60",
        labelText: "Intervallo Incartonatrice (secondi)",
        floatingLabelStyle: TextStyle(
          color: Colors.teal
        ),
        icon: Icon(Icons.timer),
        iconColor: Colors.teal,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
      )
    );
  }

  Widget _saveButton() {
    return ElevatedButton(
      onPressed: _updateSecondsInterval,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(350, 60),
        backgroundColor: Colors.teal
      ),
      child: const Text(
        "Salva",
        style: TextStyle(
          color: Colors.white
        ),
      )
    );
  }

  Widget _resetButton() {
    return ElevatedButton(
      onPressed: _resetSimulation,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(350, 60),
        backgroundColor: Colors.red
      ),
      child: const Text(
        "Reset Simulazione",
        style: TextStyle(
          color: Colors.white
        ),
      )
    );
  }
}