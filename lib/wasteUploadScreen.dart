import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/classifier.dart';
import '../utils/price_detector.dart';
import '../utils/hotspot.dart';
import 'package:abwm/Services/api_services.dart';
import 'package:abwm/waste_hotspot.dart';

class UploadWasteScreen extends StatefulWidget {
  @override
  _UploadWasteScreenState createState() => _UploadWasteScreenState();
}

class _UploadWasteScreenState extends State<UploadWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _uploadedByController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _qualityController = TextEditingController();

  final List<String> _districts = [
    'Alappuzha', 'Ernakulam', 'Idukki', 'Kannur', 'Kasaragod', 'Kollam',
    'Kottayam', 'Kozhikode', 'Malappuram', 'Palakkad', 'Pathanamthitta',
    'Thiruvananthapuram', 'Thrissur', 'Wayanad',
  ];
  String? _selectedDistrict;

  File? _image;
  late WasteClassifier _classifier;
  late PriceDetector _priceDetector;
  late HotspotClassifier _hotspotClassifier;
  bool _isClassifying = false;
  bool _isPriceDetecting = false;
  bool _isModelLoading = true;
  bool _isPriceModelLoading = true;
  bool _isHotspotModelLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _classifier = WasteClassifier();
    _priceDetector = PriceDetector();
    _hotspotClassifier = HotspotClassifier();
    _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      await _classifier.loadModel();
      setState(() => _isModelLoading = false);
      await _priceDetector.loadModel();
      setState(() => _isPriceModelLoading = false);
      await _hotspotClassifier.loadModel();
      setState(() => _isHotspotModelLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load models: $e')),
      );
      setState(() {
        _isModelLoading = false;
        _isPriceModelLoading = false;
        _isHotspotModelLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    if (_isModelLoading || _isPriceModelLoading || _isHotspotModelLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please wait, models are loading')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isClassifying = true;
        _isPriceDetecting = true;
      });

      try {
        String wasteClass = await _classifier.classifyImage(_image!);
        double quality = 0.8;
        double basePrice = await _priceDetector.predictPrice(wasteClass, quality);

        setState(() {
          _typeController.text = wasteClass;
          _basePriceController.text = basePrice.toStringAsFixed(2);
          _priceController.text = basePrice.toStringAsFixed(2);
          _qualityController.text = quality.toStringAsFixed(2);
          _isClassifying = false;
          _isPriceDetecting = false;
        });
      } catch (e) {
        setState(() {
          _typeController.text = 'error';
          _basePriceController.text = '0.00';
          _priceController.text = '0.00';
          _qualityController.text = '0.00';
          _isClassifying = false;
          _isPriceDetecting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
      }
    }
  }

  Future<void> _uploadWaste() async {
  if (_formKey.currentState!.validate() && _image != null && _selectedDistrict != null) {
    final waste = {
      'type': _typeController.text,
      'quantity': double.parse(_quantityController.text),
      'price': double.parse(_priceController.text),
      'quality': double.parse(_qualityController.text),
      'location': _selectedDistrict,
      'uploadedBy': _uploadedByController.text,
    };

    setState(() => _isUploading = true);
    try {
      await ApiService.uploadWaste(waste, _image!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Waste uploaded successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WasteHotspotScreen(
            initialDistrict: _selectedDistrict,
            wasteType: _typeController.text,
            quantity: double.parse(_quantityController.text),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload waste: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please upload an image, select a district, and fill all fields')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Waste'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade800, Colors.green.shade200],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _isModelLoading || _isPriceModelLoading || _isHotspotModelLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.white))
                      : _image == null
                          ? Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.green.shade600.withOpacity(0.2),
                              child: Center(child: Text('No image selected', style: TextStyle(color: Colors.white))),
                            )
                          : Stack(
                              children: [
                                Image.file(_image!, height: 200, fit: BoxFit.cover),
                                if (_isClassifying || _isPriceDetecting)
                                  Center(child: CircularProgressIndicator(color: Colors.white)),
                              ],
                            ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Upload Image'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(
                      labelText: 'Waste Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.green.shade700.withOpacity(0.2),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    validator: (value) => value!.isEmpty ? 'Please enter waste type' : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity (kg)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.green.shade700.withOpacity(0.2),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter quantity';
                      if (double.tryParse(value) == null) return 'Please enter a valid number';
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _basePriceController,
                    decoration: InputDecoration(
                      labelText: 'Base Price (per kg)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.green.shade700.withOpacity(0.2),
                      labelStyle: TextStyle(color: Colors.white),
                      enabled: false,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Final Price (per kg)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.green.shade700.withOpacity(0.2),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter price';
                      if (double.tryParse(value) == null) return 'Please enter a valid number';
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _qualityController,
                    decoration: InputDecoration(
                      labelText: 'Quality (0-1)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.green.shade700.withOpacity(0.2),
                      labelStyle: TextStyle(color: Colors.white),
                      enabled: false,
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedDistrict,
                    decoration: InputDecoration(
                      labelText: 'District',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.green.shade700.withOpacity(0.2),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    items: _districts.map((String district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district, style: TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDistrict = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a district' : null,
                    dropdownColor: Colors.green.shade200,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _uploadedByController,
                    decoration: InputDecoration(
                      labelText: 'Uploaded By (Your Email)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.green.shade700.withOpacity(0.2),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _isUploading
                      ? CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                          onPressed: _uploadWaste,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Submit', style: TextStyle(fontSize: 16)),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _classifier.close();
    _priceDetector.close();
    _hotspotClassifier.close();
    _typeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _basePriceController.dispose();
    _qualityController.dispose();
    _uploadedByController.dispose();
    super.dispose();
  }
}