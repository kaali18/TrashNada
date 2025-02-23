import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/waste_models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Upload waste
  static Future<void> uploadWaste(Map<String, dynamic> waste) async {
    final url = Uri.parse('$baseUrl/upload');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(waste),
    );

    if (response.statusCode == 201) {
      print('Waste uploaded successfully!');
    } else {
      throw Exception('Failed to upload waste.');
    }
  }

  // Get all waste items
  static Future<List<Waste>> getWasteItems() async {
    final url = Uri.parse('$baseUrl/waste-items');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Waste.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch waste items.');
    }
  }

  // Purchase waste
  static Future<void> purchaseWaste(String id) async {
    final url = Uri.parse('$baseUrl/purchase/$id');
    final response = await http.put(url);

    if (response.statusCode == 200) {
      print('Waste purchased successfully!');
    } else {
      throw Exception('Failed to purchase waste.');
    }
  }
  
}
