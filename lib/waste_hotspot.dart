import 'package:flutter/material.dart';
import 'package:abwm/utils/hotspot.dart';

class WasteHotspotScreen extends StatefulWidget {
  final String? initialDistrict;
  final String? wasteType;
  final double? quantity;

  WasteHotspotScreen({this.initialDistrict, this.wasteType, this.quantity});

  // Static variable to persist hotspots across instances
  static List<Map<String, dynamic>> persistedHotspots = [];

  @override
  _WasteHotspotScreenState createState() => _WasteHotspotScreenState();
}

class _WasteHotspotScreenState extends State<WasteHotspotScreen> {
  List<Map<String, dynamic>> _hotspots = [];
  bool _isLoading = true;
  bool _hasError = false;
  late HotspotClassifier _hotspotClassifier;

  @override
  void initState() {
    super.initState();
    _hotspotClassifier = HotspotClassifier();
    _loadModelAndFetchHotspots();
  }

  Future<void> _loadModelAndFetchHotspots() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      await _hotspotClassifier.loadModel();
      if (_hotspotClassifier.isModelLoaded) {
        // If parameters are provided (from UploadWasteScreen), predict and update persisted data
        if (widget.initialDistrict != null && widget.wasteType != null && widget.quantity != null) {
          final hotspots = await _hotspotClassifier.predictHotspots(
            widget.initialDistrict!,
            widget.wasteType!,
            widget.quantity!,
          );
          WasteHotspotScreen.persistedHotspots = hotspots; // Save to static variable
          setState(() {
            _hotspots = hotspots;
            _isLoading = false;
          });
        } else {
          // Use persisted hotspots if available, otherwise empty
          setState(() {
            _hotspots = WasteHotspotScreen.persistedHotspots;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Hotspot model failed to load');
      }
    } catch (e) {
      print('Error loading model or fetching hotspots: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load waste hotspots: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waste Hotspots'),
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load hotspots. Tap to retry.',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _loadModelAndFetchHotspots,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _hotspots.isEmpty
                    ? Center(
                        child: Text(
                          'No waste hotspots available. Upload waste to see predictions.',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.0),
                        itemCount: _hotspots.length,
                        itemBuilder: (context, index) {
                          final hotspot = _hotspots[index];
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.green.shade600.withOpacity(0.2),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade700,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                hotspot['district'] ?? 'Unknown',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Score: ${hotspot['score']?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  @override
  void dispose() {
    _hotspotClassifier.close();
    super.dispose();
  }
}