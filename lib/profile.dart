import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property/addProperty.dart';
import 'package:property/authentication.dart';


import 'main.dart'; // Import the AddPropertyForm

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  User? _user;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  Future<void> _handleSignIn() async {
    try {
      // Remove the Google Sign-In code
      // ...

      // Navigate to the Authentication page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthenticationPage()),
      );
    } catch (error) {
      print("Error signing in: $error");
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await _auth.signOut();

      setState(() {
        _user = null;
      });
    } catch (error) {
      print("Error signing out: $error");
    }
  }



  Future<void> _addProperty(
      String title, String description, XFile? image, String location) async {
    try {
      String imageUrl = '';

      if (image != null) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('property_images/${DateTime.now()}.png');
        UploadTask uploadTask = storageReference.putFile(File(image.path!));

        await uploadTask.whenComplete(() async {
          imageUrl = await storageReference.getDownloadURL();
        });
      }

      await FirebaseFirestore.instance.collection('properties').add({
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'location': location,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding property: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF013c7e),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (context) => PropertyListScreen()),
          //     );
          //   },
          //   icon: Icon(Icons.close),
          // ),

        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _user != null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_user!.photoURL ?? ''),
                ),
                SizedBox(height: 20),
                Text(
                  _user!.displayName ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _user!.email ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            )
                : Text(
              'Please sign in to Add property as an agent.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Sign-in and Sign-out button
            ElevatedButton(
              onPressed: () {
                if (_user == null) {
                  _handleSignIn();
                } else {
                  _handleSignOut();
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF013c7e), // Set the desired background color
              ),
              child: Text(_user == null ? 'Sign In' : 'Sign Out'),
            ),


          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1, // Set the current index for the Profile page
        onTap: (index) {
          // Handle tap on Bottom Navigation Bar items
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
      ),


      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white, // Set the drawer header color to white
              ),
              child: Image.asset(
                'assets/Images/AHBLOGO.jpg', // Adjust the path accordingly
                // fit: BoxFit.cover,
              ),
            ),
            // ListTile(
            //   title: Text('Back To Homepage'),
            //   onTap: () {
            //     Navigator.pop(context); // Close the drawer
            //     Navigator.pop(context);
            //   },
            // ),
            ListTile(
              title: Text('Close'),
              onTap: () => Navigator.pop(context), // Close the drawer
            ),
          ],
        ),
      ),
      floatingActionButton: _user != null
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AddPropertyPage()),
          );
        },
        label: Text('Add Property'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.green,
      )
          : null,
      // If user is not signed in, hide the button
    );


  }
}