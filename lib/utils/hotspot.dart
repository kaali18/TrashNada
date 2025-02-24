import 'package:tflite_flutter/tflite_flutter.dart';

class HotspotClassifier {
  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  // List of 14 districts in Kerala
  final List<String> districts = [
    'Alappuzha', 'Ernakulam', 'Idukki', 'Kannur', 'Kasaragod', 'Kollam',
    'Kottayam', 'Kozhikode', 'Malappuram', 'Palakkad', 'Pathanamthitta',
    'Thiruvananthapuram', 'Thrissur', 'Wayanad',
  ];

  // Waste types expected by the model
  final List<String> wasteTypes = ['plastic', 'metal', 'paper', 'cardboard', 'trash', 'glass'];

  HotspotClassifier();

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/waste_hotspot_model.tflite');
      _interpreter.allocateTensors();
      _isModelLoaded = true;
      print('Hotspot model loaded successfully');
    } catch (e) {
      print('Failed to load hotspot model: $e');
      _isModelLoaded = false;
    }
  }

  bool get isModelLoaded => _isModelLoaded;

  Future<List<Map<String, dynamic>>> predictHotspots(String inputDistrict, String wasteType, double quantity) async {
    if (!_isModelLoaded) {
      throw Exception('Hotspot model not loaded');
    }

    // Prepare input based on waste type and quantity
    final input = List.generate(wasteTypes.length, (index) {
      return wasteTypes[index] == wasteType.toLowerCase() ? quantity : 0.0;
    });

    // Output: Single probability value [1, 1]
    var output = List.filled(1, 0.0).reshape([1, 1]);

    // Run inference
    _interpreter.run([input], output);

    // Extract hotspot probability for the input district
    double probHotspot = output[0][0];

    // Simulate rankings for all districts (since model gives one score)
    // In a real model, this might output 14 scores; adjust if so
    final rankedHotspots = districts.map((district) {
      // Boost the input district; others get a scaled-down score
      double score = district == inputDistrict ? probHotspot : probHotspot * (0.9 - districts.indexOf(district) * 0.05);
      return {
        'district': district,
        'score': score.clamp(0.0, 1.0), // Ensure score stays between 0 and 1
      };
    }).toList();

    // Sort by score descending
    rankedHotspots.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    print('Predicted hotspots: $rankedHotspots');
    return rankedHotspots;
  }

  void close() {
    if (_isModelLoaded) {
      _interpreter.close();
    }
  }
}