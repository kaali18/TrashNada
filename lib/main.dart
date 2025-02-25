import 'package:flutter/material.dart';
import 'package:abwm/Chatbot.dart';
import 'package:abwm/LandingPage.dart';
import 'package:abwm/approval.dart';
import 'package:abwm/wasteUploadScreen.dart';
import 'package:abwm/waste_hotspot.dart';
import 'package:abwm/wastemarketplace.dart';

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
      home: LandingPage(),
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
          image: DecorationImage(
            image: AssetImage('assets/login_bg.jpeg'),
            fit: BoxFit.cover, // Cover the entire screen
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
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
                      'Welcome, $_userName!',
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
                    Wrap(
                      spacing: 20, // Increased horizontal spacing for symmetry
                      runSpacing: 20, // Increased vertical spacing for symmetry
                      alignment: WrapAlignment.center, // Center the boxes
                      children: [
                        _buildActionBox(
                          context: context,
                          title: 'SELL',
                          icon: Icons.handshake,
                          color: Colors.blue.shade200,
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
                          color: Colors.green.shade200,
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
                          color: Colors.orange.shade200,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WasteHotspotScreen()),
                            );
                          },
                        ),
                        _buildActionBox(
                          context: context,
                          title: 'Requests',
                          icon: Icons.request_page,
                          color: Colors.purple.shade200,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ApprovalScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
              // Chatbot FAB at bottom right
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
                  mini: true,
                  child: Icon(Icons.chat, color: Colors.white),
                ),
              ),
              // About Us icon at top right
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.info_outline, color: Colors.white, size: 24),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUsScreen()),
                    );
                  },
                  tooltip: 'About Us',
                ),
              ),
            ],
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
      width: 150,
      height: 120,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: color,
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
                  color: Colors.black87,
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
}

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_bg.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Text(
            'About TrashNada\n\n'
            'TrashNada is a platform to facilitate waste management and recycling.\n'
            'Our mission is to connect waste producers and recyclers efficiently.\n'
            'An innovation by Alpha Innovations,\n KASINATH K V \n ABIJITH A B \n ASWIN M KUMAR \n GOKUL B',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}