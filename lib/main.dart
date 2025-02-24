import 'package:abwm/Chatbot.dart';
import 'package:abwm/LandingPage.dart';

import 'package:abwm/wasteUploadScreen.dart';
//import 'package:abwm/Services/api_services.dart';
import 'package:abwm/waste_hotspot.dart';
import 'package:abwm/wastemarketplace.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrashNada',
      theme: ThemeData(
        primarySwatch: Colors.green,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
        ),
      ),
      home: LandingPage(), // Start with signup; change to HomeScreen if needed after login
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User'; // Placeholder for user name; update dynamically if needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade800, Colors.green.shade200], // Matching gradient from login page
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'TrashNada',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome, $_userName!', // Welcome message
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                // Grid of 4 colorful boxes (2x2 layout)
                Wrap(
                  spacing: 16, // Horizontal spacing between boxes
                  runSpacing: 16, // Vertical spacing between rows
                  alignment: WrapAlignment.center,
                  children: [
                    _buildActionBox(
                      context: context,
                      title: 'SELL',
                      icon: Icons.handshake,
                      color: Colors.blue.shade200, // Light blue, similar to "Learning"
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UploadWasteScreen()),
                        );
                      },
                    ),
                    _buildActionBox(
                      context: context,
                      title: 'BUY',
                      icon: Icons.recycling,
                      color: Colors.green.shade200, // Light green, similar to "Path Finder"
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WasteItemsScreen()),
                        );
                      },
                    ),
                    _buildActionBox(
                      context: context,
                      title: 'Hotspots',
                      icon: Icons.location_on,
                      color: Colors.orange.shade200, // Light orange, similar to "Jobs"
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WasteHotspotScreen()),
                        );
                      },
                    ),
                    _buildActionBox(
                      context: context,
                      title: 'About Us',
                      icon: Icons.info,
                      color: Colors.purple.shade200, // Light purple, similar to "Community"
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AboutUsScreen()),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 40),
                // Small chatbot button (bottom right, floating-like, unchanged)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatScreen()),
                        );
                    },
                    backgroundColor: Colors.green.shade600,
                    mini: true, // Small button
                    child: Icon(Icons.chat, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBox({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 150, // Fixed width for consistency
      height: 120, // Fixed height to match the screenshot
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: color, // Use the specified color for each box
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: Colors.black87, // Dark text/icon for contrast
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Dark text for readability
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void _showChatBotDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('ChatBot'),
  //       content: Text('Hello! How can I assist you with TrashNada?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
              
  //           },
  //           child: Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

// Placeholder classes for Settings and About Us screens


class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Us'), backgroundColor: Colors.green.shade700),
      body: Center(child: Text('About Us Screen')),
    );
  }
}