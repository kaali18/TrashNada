import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:abwm/models/waste_models.dart';

class RecommendationClassifier {
  Interpreter? _interpreter;
  bool isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/waste_recommendation_model.tflite');
      isModelLoaded = true;
      print('Recommendation model loaded successfully');
      
      // Print model input/output details for debugging
      final inputDetails = _interpreter!.getInputTensor(0);
      final outputDetails = _interpreter!.getOutputTensor(0);
      print('Input tensor shape: ${inputDetails.shape}');
      print('Output tensor shape: ${outputDetails.shape}');
    } catch (e) {
      print('Error loading recommendation model: $e');
      throw e;
    }
  }

  Future<List<double>> recommendWastes(String userType, List<Waste> wastes) async {
    if (!isModelLoaded || _interpreter == null) {
      print('Recommendation model not loaded yet');
      return List<double>.filled(wastes.length, 0.5); // Default score if model fails
    }

    if (wastes.isEmpty) {
      print('No waste items provided for recommendation');
      return List<double>.filled(0, 0.5); // Return empty list of scores
    }

    try {
      // Get model input/output shapes
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      print('Model expects input shape: $inputShape');
      print('Model expects output shape: $outputShape');

      // Prepare normalized input data: [batch_size, 4] (userType, wasteType, quantity, price)
      List<List<double>> inputData = [];
      for (var waste in wastes) {
        List<double> features = [
          _normalizeUserType(userType),
          _normalizeWasteType(waste.type),
          _normalizeQuantity(waste.quantity),
          _normalizePrice(waste.price),
        ];
        inputData.add(features);
      }

      // Ensure input matches model shape (add batch dimension if needed)
      List<List<List<double>>> input = [inputData]; // [1, batch_size, 4]
      if (inputShape[0] != 1 || inputShape[1] != wastes.length || inputShape[2] != 4) {
        print('Input shape mismatch: Expected [1, ${wastes.length}, 4], got $inputShape');
        throw Exception('Input shape mismatch with model');
      }

      // Prepare output: [1, batch_size] (scores for each waste)
      List<List<double>> output = List.generate(1, (_) => List<double>.filled(wastes.length, 0.0));
      if (outputShape[0] != 1 || outputShape[1] != wastes.length) {
        print('Output shape mismatch: Expected [1, ${wastes.length}], got $outputShape');
        throw Exception('Output shape mismatch with model');
      }

      // Run inference
      print('Running inference with input: $input');
      _interpreter!.run(input, output);
      print('Raw model output: $output');

      // Extract and process scores
      List<double> scores = output[0].map((score) => _processScore(score)).toList();
      print('Processed scores: $scores');

      return scores;
    } catch (e, stackTrace) {
      print('Recommendation error: $e');
      print('Stack trace: $stackTrace');
      return List<double>.filled(wastes.length, 0.5); // Default score if error
    }
  }

  // Normalize input values to range [0,1]
  double _normalizeUserType(String userType) {
    final Map<String, double> userTypeScores = {
      'industry': 1.0,
      'farmer': 0.8,
      'collector': 0.9,
      'other': 0.7,
    };
    return userTypeScores[userType.toLowerCase()] ?? 0.5;
  }

  double _normalizeWasteType(String wasteType) {
    final Map<String, double> wasteTypeScores = {
      'plastic': 1.0,
      'metal': 0.9,
      'cardboard': 0.9,
      'paper': 0.8,
      'glass': 0.7,
      'trash': 0.6,
    };
    return wasteTypeScores[wasteType.toLowerCase()] ?? 0.5;
  }

  double _normalizeQuantity(double quantity) {
    // Normalize quantity to [0,1] range, assuming max quantity is 100
    return (quantity.clamp(0, 100)) / 100;
  }

  double _normalizePrice(double price) {
    // Normalize price to [0,1] range, assuming max price is 100
    return (price.clamp(0, 100)) / 100;
  }

  double _processScore(double score) {
    // Ensure score is in [0,1] range and handle NaN/infinity
    if (score.isNaN || score.isInfinite) {
      return 0.5;
    }
    return score.clamp(0, 1);
  }

  void close() {
    _interpreter?.close();
  }
}