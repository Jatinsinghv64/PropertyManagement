import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';


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
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("User cancelled Google Sign-In");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential authResult = await _auth.signInWithCredential(credential);
      User? user = authResult.user;

      print("Successfully signed in with Google: ${user?.displayName}");

      _checkCurrentUser();
      if (user != null) {
        _showAddPropertyForm(context); // Navigate to the AddPropertyForm if signed in
      }
    } catch (error) {
      print("Error signing in with Google: $error");
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await _auth.signOut();
      await googleSignIn.signOut();

      setState(() {
        _user = null;
      });
    } catch (error) {
      print("Error signing out: $error");
    }
  }

  void _showAddPropertyForm(BuildContext context) async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddPropertyForm(
          onAddProperty: (title, description, location) {
            _addProperty(title, description, image, location);
          },
        );
      },
    );
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
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
          ),
        ],
      ),
      body: Center(
        child: _user != null
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _user!.email ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        )
            : Text(
          'Please sign in to view your profile.',
          style: TextStyle(fontSize: 18),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            if (_user == null)
              ListTile(
                title: Text('Sign In with Google'),
                onTap: _handleSignIn,
              ),
            if (_user != null)
              ListTile(
                title: Text('Sign Out'),
                onTap: _handleSignOut,
              ),
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
          _showAddPropertyForm(context);
        },
        label: Text('Add Property'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.green,
      )
          : null, // If user is not signed in, hide the button
    );
  }
}