import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
//import 'dart:typed_data';
import 'dart:math' as math;

class WasteClassifier {
  Interpreter? _interpreter;
  final List<String> labels = ['plastic', 'metal', 'paper', 'cardboard', 'trash', 'glass'];
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/waste_classifier2.tflite');
      _isModelLoaded = true;
      print('Waste classification model loaded successfully');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      print('Error loading waste classification model: $e');
      throw Exception('Failed to load waste classification model: $e');
    }
  }

  Future<String> classifyImage(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      print('Model not loaded');
      return 'trash';
    }

    try {
      img.Image? image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) {
        print('Failed to decode image');
        return 'error';
      }

      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
      var input = _preprocessImage(resizedImage);

      var output = List.filled(1, List.filled(6, 0.0));
      _interpreter!.run(input, output);
      print('Raw output: ${output[0]}');

      double maxScore = output[0].reduce(math.max);
      int maxIndex = output[0].indexOf(maxScore);
      
      if (maxScore < 0.3) {
        print('Confidence too low: $maxScore');
        return 'trash';
      }
      
      return labels[maxIndex];
    } catch (e) {
      print('Classification error: $e');
      return 'error';
    }
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    return List.generate(1, (_) => 
      List.generate(224, (y) => 
        List.generate(224, (x) {
          var pixel = image.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        })
      )
    );
  }

  void close() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}