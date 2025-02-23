import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../utils/classifier.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _sellerController = TextEditingController();
  String? _wasteType;
  File? _image;
  late WasteClassifier _classifier;
  bool _isClassifying = false;
  bool _isModelLoading = true;

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
      setState(() => _isModelLoading = false);
      print('Model load failed: $e');
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
        print('Classification result: $type');
        setState(() {
          _wasteType = type;
          _isClassifying = false;
        });
      } catch (e) {
        print('Error classifying image: $e');
        setState(() {
          _wasteType = 'Error';
          _isClassifying = false;
        });
      }
    }
  }

  Future<void> uploadWaste() async {
    if (_wasteType == null || _image == null) return;
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/waste'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'type': _wasteType,
        'quantity': int.parse(_quantityController.text),
        'price': double.parse(_priceController.text),
        'seller': _sellerController.text,
      }),
    );
    if (response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      print('Upload failed: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Waste')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _isModelLoading
                  ? Center(child: CircularProgressIndicator())
                  : _image == null
                      ? Text('No image selected')
                      : Image.file(_image!, height: 200),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Image'),
              ),
              SizedBox(height: 10),
              _isClassifying
                  ? CircularProgressIndicator()
                  : Text(_wasteType != null ? 'Detected: $_wasteType' : 'Awaiting classification'),
              SizedBox(height: 10),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _sellerController,
                decoration: InputDecoration(labelText: 'Your Name'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: uploadWaste,
                child: Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _classifier.close();
    super.dispose();
  }
}