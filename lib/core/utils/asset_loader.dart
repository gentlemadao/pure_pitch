import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AssetLoader {
  static Future<String> loadModelPath(String modelName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$modelName';
    final file = File(filePath);
    
    // Check if file exists, if not, copy it from assets
    if (!await file.exists()) {
      final byteData = await rootBundle.load('assets/models/$modelName');
      await file.writeAsBytes(byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ));
    }
    
    return filePath;
  }
}