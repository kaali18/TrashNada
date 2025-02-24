import 'package:flutter/material.dart';
import 'package:abwm/approval.dart';
import 'package:abwm/utils/reccomentation_classifier.dart'; // Note: Correct spelling if it's 'recommendation_classifier.dart'
import 'package:abwm/wasteUploadScreen.dart';
import 'package:abwm/Services/api_services.dart';
import 'package:abwm/models/waste_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:abwm/login_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class WasteItemsScreen extends StatefulWidget {
  @override
  _WasteItemsScreenState createState() => _WasteItemsScreenState();
}

class _WasteItemsScreenState extends State<WasteItemsScreen> {
  List<Waste> _wasteItems = [];
  late RecommendationClassifier _recommendationClassifier;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _recommendationClassifier = RecommendationClassifier();
    _loadModelAndUserData();
  }

  Future<void> _loadModelAndUserData() async {
    await _recommendationClassifier.loadModel();
    print('Model loaded: ${_recommendationClassifier.isModelLoaded}');
    await _fetchUserRole();
    await _fetchWasteItems();
  }

  Future<void> _fetchUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      print('Decoded token in _fetchUserRole: $decodedToken');
      setState(() {
        _userRole = decodedToken['role'] as String? ?? 'other';
      });
    } else {
      print('No token found in _fetchUserRole');
      setState(() {
        _userRole = 'other'; // Default role if no token
      });
    }
  }

  Future<void> _fetchWasteItems() async {
    try {
      print('Fetching waste items...');
      final wasteItems = await ApiService.getWasteItems();
      print('Fetched waste items: $wasteItems');

      // Apply sorting based on user role if possible
      if (_userRole != null && _recommendationClassifier.isModelLoaded) {
        try {
          final scores = await _recommendationClassifier.recommendWastes(_userRole!, wasteItems);
          print('Scores from recommendation: $scores');
          if (scores.length == wasteItems.length) {
            _sortWasteItems(wasteItems, scores);
          } else {
            print('Score length (${scores.length}) does not match waste length (${wasteItems.length})');
            setState(() => _wasteItems = wasteItems); // Use unsorted list
          }
        } catch (e) {
          print('Error sorting waste items: $e');
          setState(() => _wasteItems = wasteItems); // Fallback to unsorted list
        }
      } else {
        print('Skipping sorting - _userRole: $_userRole, Model loaded: ${_recommendationClassifier.isModelLoaded}');
        setState(() => _wasteItems = wasteItems); // Use unsorted list
      }
    } catch (e) {
      print('Fetch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch waste items: $e')),
      );
    }
  }

  void _sortWasteItems(List<Waste> wastes, List<double> scores) {
    if (wastes.length != scores.length) {
      print('Warning: Number of wastes (${wastes.length}) does not match number of scores (${scores.length})');
      setState(() => _wasteItems = wastes); // Fallback to unsorted list
      return;
    }

    final List<MapEntry<Waste, double>> scoredWastes = [];
    for (int i = 0; i < wastes.length; i++) {
      scoredWastes.add(MapEntry(wastes[i], scores[i]));
    }

    scoredWastes.sort((a, b) => b.value.compareTo(a.value)); // Sort descending (higher score first)
    final sortedWastes = scoredWastes.map((entry) => entry.key).toList();

    setState(() {
      _wasteItems = sortedWastes; // Update _wasteItems with sorted list
    });
  }

  Future<void> _purchaseWaste(Waste waste) async {
    if (waste.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Waste item has no ID')),
      );
      return;
    }

    try {
      print('Attempting to purchase waste with ID: ${waste.id}');
      await ApiService.purchaseWaste(waste.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase request sent successfully!')),
      );
      await _fetchWasteItems(); // Refresh the list after purchase
    } catch (e) {
      print('Purchase error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to purchase waste: $e')),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void dispose() {
    _recommendationClassifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waste Marketplace'),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.approval),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ApprovalScreen()),
            ).then((_) => _fetchWasteItems()), // Refresh on return from ApprovalScreen
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade800, Colors.green.shade200],
          ),
        ),
        child: _wasteItems.isEmpty
            ? Center(child: Text('No waste items available'))
            : ListView.builder(
                itemCount: _wasteItems.length,
                itemBuilder: (context, index) {
                  final waste = _wasteItems[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    child: ListTile(
                      leading: waste.image != null
                          ? Image.network(
                              'http://10.10.157.116:3000${waste.image}',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                            )
                          : Icon(Icons.image_not_supported),
                      title: Text('${waste.type} - ${waste.quantity} kg'),
                      subtitle: Text('Price: \$${waste.price.toStringAsFixed(2)}/kg | Location: ${waste.location}'),
                      trailing: waste.sold
                          ? Text('Sold', style: TextStyle(color: Colors.red))
                          : ElevatedButton(
                              onPressed: () => _purchaseWaste(waste),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Request Purchase'),
                            ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UploadWasteScreen()),
        ).then((_) => _fetchWasteItems()), // Refresh after uploading
        backgroundColor: Colors.green.shade700,
        child: Icon(Icons.add),
      ),
    );
  }
}