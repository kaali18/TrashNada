import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class WasteClassifier {
  Interpreter? _interpreter;
  final List<String> labels = ['plastic', 'metal', 'paper', 'cardboard', 'trash', 'glass']; // Updated to 6 classes
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/waste_classifier2.tflite'); // Updated model path
      _isModelLoaded = true;
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
      throw e;
    }
  }

  Future<String> classifyImage(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      print('Model not loaded yet');
      return 'Error: Model not loaded';
    }

    try {
      // Decode and preprocess image
      img.Image? image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) return 'Error decoding image';
      print('Image decoded: ${image.width}x${image.height}');

      // Resize to match model input (224x224 as per Python script)
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
      print('Image resized to 224x224');

      // Preprocess image (convert to RGB, normalize [0, 1], add batch dimension)
      var input = _preprocessImage(resizedImage);
      print('Input prepared: ${input.length}x${input[0].length}x${input[0][0].length}x3');

      // Prepare output buffer for 6 classes
      List<List<double>> output = List.generate(1, (_) => List.filled(6, 0.0)); // Updated to [1, 6]
      print('Output buffer ready: ${output.length}x${output[0].length}');

      // Run inference
      _interpreter!.run(input, output);
      print('Inference output: $output');

      // Get predicted class (highest probability)
      int maxIndex = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
      print('Predicted class: ${labels[maxIndex]}');
      return labels[maxIndex];
    } catch (e) {
      print('Classification error: $e');
      return 'Error';
    }
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Convert to RGB and normalize to [0, 1], as per Python script
    List<List<List<List<double>>>> input = List.generate(
      1, // Batch dimension
      (_) => List.generate(
        224, // Height
        (y) => List.generate(
          224, // Width
          (x) {
            var pixel = image.getPixel(x, y);
            // Use RGB (not BGR as in OpenCV's default), normalize to [0, 1]
            return [
              pixel.r / 255.0, // Red
              pixel.g / 255.0, // Green
              pixel.b / 255.0, // Blue
            ];
          },
        ),
      ),
    );
    return input;
  }

  void close() {
    _interpreter?.close();
  }
}