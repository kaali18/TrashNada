import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/waste_models.dart';

class ApiService {
  static const String baseUrl = 'http://10.10.157.116:3000/api'; // Your IP

  // Signup
  static Future<String> signup(String email, String password, String role) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'role': role}),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return token;
    } else {
      throw Exception('Failed to signup: ${response.body}');
    }
  }

  // Login
  static Future<String> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return token;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Upload waste
  static Future<void> uploadWaste(Map<String, dynamic> waste, File image) async {
    final url = Uri.parse('$baseUrl/upload');
    var request = http.MultipartRequest('POST', url);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('No token found');

    request.headers['Authorization'] = 'Bearer $token';

    waste.forEach((key, value) {
      request.fields[key] = value.toString();
      print('Adding field: $key = $value'); // Debug
    });
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    try {
      print('Sending upload request to: $url with headers: ${request.headers}');
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      if (response.statusCode != 201) {
        print('Response body: ${responseBody.body}');
        throw Exception('Failed to upload waste: ${response.statusCode} - ${responseBody.body}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get waste items
  static Future<List<Waste>> getWasteItems() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) throw Exception('No token found');

  print('Fetching waste items from: $baseUrl/waste-items with token: $token');
  final response = await http.get(
    Uri.parse('$baseUrl/waste-items'),
    headers: {'Authorization': 'Bearer $token'},
  );
  print('Response: ${response.statusCode} - ${response.body}');

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    print('Parsed waste items before mapping: $data');
    return data.map((json) {
      // Add detailed error logging
      try {
        print('Processing waste item: $json');
        final waste = Waste.fromJson(json);
        print('Successfully parsed waste item: ${waste.type}');
        return waste;
      } catch (e, stackTrace) {
        print('Error parsing waste item: $json');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        // Return a default waste item instead of throwing
        return Waste(
          type: 'Error',
          quantity: 0,
          price: 0,
          location: 'Unknown',
          uploadedBy: 'Unknown',
        );
      }
    }).toList();
  } else {
    throw Exception('Failed to fetch waste items: ${response.body}');
  }
}

  // Send purchase request
  static Future<void> purchaseWaste(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('No token found');

    print('Sending POST to: $baseUrl/purchase/$id with token: $token');
    final response = await http.post(
      Uri.parse('$baseUrl/purchase/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to send purchase request: ${response.body}');
    }
  }

  // Get pending requests (for seller)
  static Future<List<Waste>> getPendingRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$baseUrl/waste-items'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final allItems = data.map((json) => Waste.fromJson(json)).toList();
      final decodedToken = JwtDecoder.decode(token);
      final userEmail = decodedToken['email'] as String;
      return allItems.where((waste) => waste.uploadedBy == userEmail && waste.purchaseRequests.isNotEmpty).toList();
    } else {
      throw Exception('Failed to fetch pending requests: ${response.body}');
    }
  }

  // Approve purchase request
  static Future<void> approvePurchase(String wasteId, String requestId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$baseUrl/approve'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode({'wasteId': wasteId, 'requestId': requestId, 'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to approve request: ${response.body}');
    }
  }
}