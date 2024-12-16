import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:granterre/components/description.dart';
import 'package:granterre/components/header.dart';
import 'package:granterre/components/title.dart';
import 'package:granterre/config.dart';
import 'package:granterre/controllers/simulation.dart';
import 'package:granterre/utils.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {

  SimulatorController simulatorController = SimulatorController();

  final TextEditingController _secondsIntervalConfezionatriceController = TextEditingController();
  final TextEditingController _secondsIntervalIncartonatriceController = TextEditingController();

  int _machineSelected = 0;
  final TextEditingController _lottoController = TextEditingController();
  final TextEditingController _codiceProdottoController = TextEditingController();
  final TextEditingController _codiceRicettaController = TextEditingController();

  @override
  void initState() {
    _secondsIntervalConfezionatriceController.text = secondsIntervalConfezionatrice.toString();
    _secondsIntervalIncartonatriceController.text = secondsIntervalIncartonatrice.toString();
    _lottoController.text = "";
    _codiceProdottoController.text = "";
    _codiceRicettaController.text = "";
    super.initState();
  }

  void _updateSecondsInterval() {
    setState(() {
      secondsIntervalConfezionatrice = int.tryParse(_secondsIntervalConfezionatriceController.text) ?? 60;
      secondsIntervalIncartonatrice = int.tryParse(_secondsIntervalIncartonatriceController.text) ?? 60;
    });
    AppUtils.showSnackBar(context, "Intervalli aggiornati correttamente", false);
  }

  void _uploadMachine(BuildContext context, String machine) async {
    Uint8List? bytes = await AppUtils.getFile();
    if (bytes != null) {
      if (!context.mounted) return;
      await simulatorController.uploadMachine(context, machine, bytes);
    } else {
      if (!context.mounted) return;
      AppUtils.showSnackBar(context, "Impossibile eseguire l'uplaoad del file", true);
    }
  }

  void _resetSimulation() {
    if (simulationConfezionatriceOn || simulationIncartonatriceOn) {
      AppUtils.showSnackBar(context, "Impossibile eseguire il reset della simulazione mentre è in corso. Interrompere prima la simulazione dei due macchinari", true);
    } else {
      AppUtils.showConfirmationDialog(context, "Sei sicuro di voler eseguire il reset della simulazione?", "Tutti i dati caricati finora saranno eliminati", () async {
        await simulatorController.resetMachines(context);
      }, isConfirmDefault: false);
    }
  }

  void _writeMachine(BuildContext context) async {
    await simulatorController.writeMachine(
      context, 
      _machineSelected, 
      _lottoController.text.trim(), 
      _codiceProdottoController.text.trim(), 
      int.tryParse(_codiceRicettaController.text) ?? 0
    );
    setState(() {
      _machineSelected = 0;
      _lottoController.text = "";
      _codiceProdottoController.text = "";
      _codiceRicettaController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {

    final isMobile = MediaQuery.of(context).size.width < 1200;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const AppTitle(text: "Simulazione"),
            const SizedBox(height: 10,),
            isMobile ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildWidgets()
            ) : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildWidgets(),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWidgets() {
    return [
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const AppHeader(big: true, text: "Configurazione Ambiente"),
          const SizedBox(height: 10),
          const AppDescription(
            text: "L'utente può simulare il caricamento dei valori in tempo reale da parte dei macchinari, impostando l'intervallo di tempo (stabilito in secondi) con cui i macchinari inviano dati al sistema"
          ),
          const SizedBox(height: 40),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _uploadConfezionatriceButton(),
              const SizedBox(height: 20),
              _uploadIncartonatriceButton()
            ]
          ),
          const SizedBox(height: 80),
          _secondsIntervalConfezionatriceField(),
          const SizedBox(height: 16),
          _secondsIntervalIncartonatriceField(),
          const SizedBox(height: 20),
          _saveButton(),
          const SizedBox(height: 80),
          const AppHeader(big: true, text: "Reset Ambiente"),
          const SizedBox(height: 10),
          const AppDescription(
            text: "Prima avviare la simulazione, è bene reimpostare i dati da zero."
          ),
          const SizedBox(height: 20),
          _resetButton(),
        ],
      ),
      const SizedBox(height: 80, width: 16),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const AppHeader(big: true, text: "Scrittura Dati"),
          const SizedBox(height: 10),
          const AppDescription(
            text: "L'utente può comunicare con i macchinari, in modalità di scrittura."
          ),
          const SizedBox(height: 40),
          _selectMachineDropDownButton(),
          const SizedBox(height: 20),
          _lottoField(),
          const SizedBox(height: 16),
          _codiceProdottoField(),
          const SizedBox(height: 16),
          _codiceRicettaField(),
          const SizedBox(height: 20),
          _sendButton(),
        ],
      ),
    ];
  }

  Widget _uploadConfezionatriceButton() {
    return ElevatedButton(
      onPressed: () {
        _uploadMachine(context, 'confezionatrice');
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(350, 60),
        backgroundColor: Colors.white
      ),
      child: const Text(
        "Carica CSV Confezionatrice",
        style: TextStyle(
          color: Colors.teal
        ),
      )
    );
  }

  Widget _uploadIncartonatriceButton() {
    return ElevatedButton(
      onPressed: () {
        _uploadMachine(context, 'incartonatrice');
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(350, 60),
        backgroundColor: Colors.white
      ),
      child: const Text(
        "Carica CSV Incartonatrice",
        style: TextStyle(
          color: Colors.teal
        ),
      )
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
        icon: Icon(Icons.timer_outlined),
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
        icon: Icon(Icons.timer_outlined),
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

  Widget _lottoField() {
    return TextField(
      controller: _lottoController,
      autocorrect: false,
      decoration: const InputDecoration(
        constraints: BoxConstraints(
          minWidth: 400,
          maxWidth: 400,
        ),
        hintText: "16L24430",
        labelText: "Lotto Richiesto",
        floatingLabelStyle: TextStyle(
          color: Colors.teal
        ),
        icon: Icon(Icons.confirmation_number_outlined),
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

  Widget _codiceProdottoField() {
    return TextField(
      controller: _codiceProdottoController,
      autocorrect: false,
      decoration: const InputDecoration(
        constraints: BoxConstraints(
          minWidth: 400,
          maxWidth: 400,
        ),
        hintText: "CGT_894012/0020",
        labelText: "Codice Prodotto Richiesto",
        floatingLabelStyle: TextStyle(
          color: Colors.teal
        ),
        icon: Icon(Icons.code_rounded),
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

  Widget _codiceRicettaField() {
    return TextField(
      controller: _codiceRicettaController,
      autocorrect: false,
      decoration: const InputDecoration(
        constraints: BoxConstraints(
          minWidth: 400,
          maxWidth: 400,
        ),
        hintText: "5",
        labelText: "Codice Ricetta Richiesta",
        floatingLabelStyle: TextStyle(
          color: Colors.teal
        ),
        icon: Icon(Icons.receipt_long_outlined),
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

  Widget _sendButton() {
    return ElevatedButton(
      onPressed: () {
        _writeMachine(context);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(350, 60),
        backgroundColor: Colors.teal
      ),
      child: const Text(
        "Invia",
        style: TextStyle(
          color: Colors.white
        ),
      )
    );
  }
}