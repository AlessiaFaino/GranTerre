import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:granterre/config.dart';
import 'package:granterre/models/machine_data.dart';
import 'package:granterre/utils.dart';
import 'package:granterre/sources/api_service.dart';
import 'package:http/http.dart';

class SimulatorController {

  static final SimulatorController _instance = SimulatorController._internal();

  factory SimulatorController() {
    return _instance;
  }

  SimulatorController._internal();

  Timer? _timerConfezionatrice;
  Timer? _timerIncartonatrice;

  final StreamController<MachineData> _dataConfezionatriceController = StreamController.broadcast();
  final StreamController<MachineData> _dataIncartonatriceController = StreamController.broadcast();
  final List<MachineData> _historyConfezionatrice = [];
  final List<MachineData> _historyIncartonatrice = [];

  Stream<MachineData> get dataConfezionatriceStream => _dataConfezionatriceController.stream;
  Stream<MachineData> get dataIncartonatriceStream => _dataIncartonatriceController.stream;
  List<MachineData> get historyConfezionatrice => _historyConfezionatrice;
  List<MachineData> get historyIncartonatrice => _historyIncartonatrice;

  Future<void> resetMachines(BuildContext context) async {
    Response response = await ApiService.callApi(path: "machines/reset", method: 'DELETE');
    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> map = json.decode(response.body);
      if (!context.mounted) return;
      AppUtils.showSnackBar(context, "Simulazione reimpostata con successo!\n${map["message"]}", false);
    } else {
      if (!context.mounted) return;
      AppUtils.showSnackBar(context, "Impossibile reimpostare la simulazione\n${response.body}", true);
    }
    indexConfezionatrice = 0;
    indexIncartonatrice = 0;
  }

  Future<void> uploadMachine(BuildContext context, String machine, Uint8List fileBytes) async {
    Response response = await ApiService.callApi(path: "machines/load-file", method: 'POST', body: {"machine": machine}, fileBytes: fileBytes);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> map = json.decode(response.body);
      if (!context.mounted) return;
      AppUtils.showSnackBar(context, "File caricato con successo!\n${map["message"]}", false);
    } else {
      if (!context.mounted) return;
      AppUtils.showSnackBar(context, "Impossibile caricare il file\n${response.body}", true);
    }
  }

  Future<void> writeMachine(BuildContext context, int machineIndex, String lotto, String codiceProdotto, int codiceRicetta) async {
    String machine = "${machines[machineIndex]}_write";
    Response response = await ApiService.callApi(path: "machines/write", method: 'POST', body: {
      "machine": machine,
      "lotto": lotto,
      "codiceProdotto": codiceProdotto,
      "codiceRicetta": codiceRicetta,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> map = json.decode(response.body);
      if (!context.mounted) return;
      AppUtils.showSnackBar(context, "Scrittura effettuata con successo!\n${map["message"]}", false);
    } else {
      if (!context.mounted) return;
      AppUtils.showSnackBar(context, "Impossibile effettuare la scrittura\n${response.body}", true);
    }
  }

  void startFetchingData(BuildContext context, int machineIndex) {
    try {
      String? machine = machines[machineIndex];
      if (machine == null) return;
      int seconds = machineIndex == 0 ? secondsIntervalConfezionatrice : secondsIntervalIncartonatrice;
      if (machineIndex == 0) {
        _timerConfezionatrice = Timer.periodic(Duration(seconds: seconds), (timer) async {
          Response response = await ApiService.callApi(path: "machines/read/$machine/$indexConfezionatrice", method: "GET");
          dynamic resp = json.decode(response.body);
          if (resp["success"] == true) {
            final MachineData machineData = MachineData.fromJson(resp["data"]);
            _dataConfezionatriceController.add(machineData);
            _historyConfezionatrice.add(machineData);
            indexConfezionatrice++;
          } else {
            timer.cancel();
            disposeConfezionatrice();
          }
        });
      } else {
        _timerIncartonatrice = Timer.periodic(Duration(seconds: seconds), (timer) async {
          Response response = await ApiService.callApi(path: "machines/read/$machine/$indexIncartonatrice", method: "GET");
          dynamic resp = json.decode(response.body);
          if (resp["success"] == true) {
            final MachineData machineData = MachineData.fromJson(resp["data"]);
            _dataIncartonatriceController.add(machineData);
            _historyIncartonatrice.add(machineData);
            indexIncartonatrice++;
          } else {
            timer.cancel();
            disposeIncartonatrice();
          }
        });
      }
      
    } catch (e) {
      AppUtils.showSnackBar(context, "Errore in fase di lettura\n${e.toString()}", true);
    }
  }

  void pauseFetchingData(BuildContext context, int machineIndex) {
    machineIndex == 0 ? _timerConfezionatrice?.cancel() : _timerIncartonatrice?.cancel();
}

  void disposeConfezionatrice() {
    _dataConfezionatriceController.close();
  }

  void disposeIncartonatrice() {
    _dataIncartonatriceController.close();
  }

}