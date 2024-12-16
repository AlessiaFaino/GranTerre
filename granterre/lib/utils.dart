import "package:flutter/material.dart";
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:csv2json/csv2json.dart';
import 'package:file_picker/file_picker.dart';

class AppUtils {
  static void showSnackBar(BuildContext context, String message, bool isError) {
    var snackBar = SnackBar(content: Text(message), backgroundColor: isError? Colors.red : Colors.green);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showConfirmationDialog(BuildContext context, String title, String content, Function onSuccess, {
      isConfirmDefault = true
    }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Annulla",
                style: TextStyle(
                  fontWeight: isConfirmDefault ? FontWeight.normal : FontWeight.bold
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                onSuccess();
                Navigator.pop(context);
              },
              child: Text(
                "Conferma",
                style: TextStyle(
                  fontWeight: isConfirmDefault ? FontWeight.bold : FontWeight.normal
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<List<Map<String, dynamic>>> csvToJson(BuildContext context, String assetPath) async {
    try {
      final csvString = await rootBundle.loadString(assetPath);
      final jsonData = csv2json(csvString);
      return jsonData;
    } catch (e) {
      if (!context.mounted) return [];
      AppUtils.showSnackBar(context, "Impossibile convertire il File CSV in formato JSON", true);
      return [];
    }
  }

  static Future<Uint8List?> getFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        return file.bytes;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

}