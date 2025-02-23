import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class WasteClassifier {
  Interpreter? _interpreter; // Change to nullable to avoid late
  final List<String> labels = ["Plastic", "Metal", "Paper", "Glass", "Organic", "Other"];
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/waste_model.tflite');
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
      img.Image? image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) return 'Error decoding image';
      print('Image decoded: ${image.width}x${image.height}');

      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
      print('Image resized to 224x224');

      var input = _preprocessImage(resizedImage);
      print('Input prepared: ${input.length}x${input[0].length}x${input[0][0].length}x3');

      var output = List.filled(6, 0.0).reshape([1, 6]);
      print('Output buffer ready: ${output.length}x${output[0].length}');

      _interpreter!.run(input, output); // Use ! since we checked null
      print('Inference output: $output');

      int maxIndex = output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
      print('Predicted class: ${labels[maxIndex]}');
      return labels[maxIndex];
    } catch (e) {
      print('Classification error: $e');
      return 'Error';
    }
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    List<List<List<List<double>>>> input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            var pixel = image.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
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