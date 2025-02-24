import 'package:abwm/login_screen.dart';
import 'package:abwm/signup.dart';
import 'package:flutter/material.dart';
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/background.jpeg', // Replace with your background image path
            fit: BoxFit.cover,
            width: screenWidth,
            height: screenHeight,
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade800.withOpacity(0.7),
                  Colors.green.shade200.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/Logo.jpeg',
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.2,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to Trash Nada',
                    style: TextStyle(
                      fontSize: screenWidth * 0.09,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupScreen()),
                      );
                    },
                    child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}