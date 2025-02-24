import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/waste_models.dart';

class ApiService {
  static const String baseUrl = 'http://10.10.157.116:3000/api';

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
    waste.forEach((key, value) => request.fields[key] = value.toString());
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    if (response.statusCode != 201) {
      throw Exception('Failed to upload waste: ${responseBody.body}');
    }
  }

  // Get waste items
  static Future<List<Waste>> getWasteItems() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) throw Exception('No token found');

  final response = await http.get(
    Uri.parse('$baseUrl/waste-items'),
    headers: {'Authorization': 'Bearer $token'},
  );
  print('Raw response from /waste-items: ${response.body}'); // Log raw JSON
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    print('Parsed waste items: $data'); // Log parsed data
    return data.map((json) => Waste.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch waste items: ${response.body}');
  }
}

  // Send purchase request
  static Future<void> purchaseWaste(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$baseUrl/purchase/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send purchase request: ${response.body}');
    }
  }

  // Get pending requests (returns List<Map<String, dynamic>>)
  static Future<List<Map<String, dynamic>>> getPendingRequests() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) throw Exception('No token found');
  //print('Token for pending requests:', token); // Log token
  //final decoded = JwtDecoder.decode(token);
  //print('Decoded token:', decoded); // Log decoded token

  final response = await http.get(
    Uri.parse('$baseUrl/pending-requests'),
    headers: {'Authorization': 'Bearer $token'},
  );
  //print('Pending requests response:', response.body); // Log response
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
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