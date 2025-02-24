import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/classifier.dart';
import 'package:abwm/Services/api_services.dart';

class UploadWasteScreen extends StatefulWidget {
  @override
  _UploadWasteScreenState createState() => _UploadWasteScreenState();
}

class _UploadWasteScreenState extends State<UploadWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _uploadedByController = TextEditingController();

  File? _image;
  late WasteClassifier _classifier;
  bool _isClassifying = false;
  bool _isModelLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _classifier = WasteClassifier();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() => _isModelLoading = true);
    try {
      await _classifier.loadModel();
      setState(() => _isModelLoading = false);
    } catch (e) {
      print('Model load failed: $e');
      setState(() => _isModelLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load model: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
  if (_isModelLoading) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please wait, model is still loading')),
    );
    return;
  }

  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      _image = File(pickedFile.path);
      _isClassifying = true;
    });
    try {
      String type = await _classifier.classifyImage(_image!);
      print('Classification result: $type'); // Now outputs one of: plastic, metal, paper, cardboard, trash, glass
      setState(() {
        _typeController.text = type; // Ensure UI reflects lowercase labels
        _isClassifying = false;
      });
    } catch (e) {
      print('Error classifying image: $e');
      setState(() {
        _typeController.text = 'Error';
        _isClassifying = false;
      });
    }
  }
}

  Future<void> _uploadWaste() async {
  if (_formKey.currentState!.validate() && _image != null) {
    final waste = {
      'type': _typeController.text,
      'quantity': double.parse(_quantityController.text),
      'price': double.parse(_priceController.text),
      'location': _locationController.text,
      'uploadedBy': _uploadedByController.text, // Can be any string now
    };

    setState(() => _isUploading = true);
    try {
      print('Uploading waste: $waste, Image: ${_image!.path}');
      await ApiService.uploadWaste(waste, _image!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Waste uploaded successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload waste: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please upload an image and fill all fields')),
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
                  _isModelLoading
                      ? Center(child: CircularProgressIndicator())
                      : _image == null
                          ? Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey.shade300,
                              child: Center(child: Text('No image selected')),
                            )
                          : Image.file(_image!, height: 200, fit: BoxFit.cover),
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
                      suffixIcon: _isClassifying ? CircularProgressIndicator() : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Please upload an image or enter waste type';
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity (kg)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
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
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price (per kg)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
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
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter location';
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _uploadedByController,
                    decoration: InputDecoration(
                      labelText: 'Uploaded By (Your Email)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _isUploading
                      ? CircularProgressIndicator()
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
    _typeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _uploadedByController.dispose();
    super.dispose();
  }
}