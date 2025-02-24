import 'package:tflite_flutter/tflite_flutter.dart';
//import 'dart:typed_data';

class PriceDetector {
  Interpreter? _interpreter;
  final List<String> labels = ['plastic', 'metal', 'paper', 'cardboard', 'trash', 'glass'];
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/advanced_price_predictor.tflite');
      _isModelLoaded = true;
      print('Price detection model loaded successfully');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      print('Error loading price detection model: $e');
      throw Exception('Failed to load price detection model');
    }
  }

  Future<double> predictPrice(String wasteType, double quality) async {
    if (!_isModelLoaded || _interpreter == null) {
      print('Price model not loaded');
      return 0.0;
    }

    try {
      // Create a mutable list for one-hot encoding
      List<double> oneHot = List<double>.generate(labels.length, (_) => 0.0);
      int index = labels.indexOf(wasteType.toLowerCase());
      if (index != -1) {
        oneHot[index] = 1.0;
      } else {
        oneHot[labels.indexOf('trash')] = 1.0; // Default to trash
      }

      // Add quality to the input list (total 7 elements)
      List<double> inputData = [...oneHot, quality.clamp(0.0, 1.0)];
      var input = [inputData]; // Shape [1, 7]
      var output = List.filled(1, List.filled(1, 0.0)); // Shape [1, 1]

      _interpreter!.run(input, output);
      print('Price output: ${output[0][0]}');

      return output[0][0].clamp(0.0, 1000.0);
    } catch (e) {
      print('Price prediction error: $e');
      return 0.0;
    }
  }

  void close() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}