import 'dart:async';

import 'package:flutter/material.dart';
import 'package:property/main.dart';
// Replace with the actual path to your home screen

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Call a function to load any initial data or perform tasks during the loading screen
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate some loading tasks
    await Future.delayed(Duration(seconds: 6));

    // Navigate to the home screen after the loading is complete
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthenticationWrapper()), // Replace with your home screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display your image here
            Image.asset(
              'assets/Images/icon.jpg', // Replace with the actual path to your image
              width: 100, // Set the width as per your requirement
              height: 100, // Set the height as per your requirement
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(), // You can customize this loading indicator
          ],
        ),
      ),
    );
  }
}