import 'dart:async';

import 'package:flutter/material.dart';
import 'package:granterre/config.dart';
import 'package:granterre/utils.dart';

class SimulatorController {
  Timer? _timerConfezionatrice;
  Timer? _timerIncartonatrice;
  int _executionConfezionatriceCount = 0;
  int _executionIncartonatriceCount = 0;

  SimulatorController();

  void startConfezionatrice(BuildContext context) {
    if (_timerConfezionatrice == null || !_timerConfezionatrice!.isActive) {
      _timerConfezionatrice = Timer.periodic(Duration(seconds: secondsIntervalConfezionatrice), (timer) async {
        if (simulationConfezionatriceOn) {
          _executionConfezionatriceCount++;
          await loadDataRow(context);
        } else {
          timer.cancel();
        }
      });
    }
  }

  void pauseConfezionatrice() {
    _timerConfezionatrice?.cancel();
  }

  int get executionConfezionatriceCount => _executionConfezionatriceCount;

  void startIncartonatrice(BuildContext context) {
    if (_timerIncartonatrice == null || !_timerIncartonatrice!.isActive) {
      _timerIncartonatrice = Timer.periodic(Duration(seconds: secondsIntervalIncartonatrice), (timer) {
        if (simulationIncartonatriceOn) {
          _executionIncartonatriceCount++;
          //TODO: upload data
        } else {
          timer.cancel();
        }
      });
    }
  }

  void pauseIncartonatrice() {
    _timerIncartonatrice?.cancel();
  }

  int get executionIncartonatriceCount => _executionIncartonatriceCount;

  Future<void> loadDataRow(BuildContext context) async {
    final jsonData = await AppUtils.csvToJson(context, "Confezionatrice.csv");
    print(jsonData);
  }

}