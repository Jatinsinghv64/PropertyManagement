import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:property/addProperty.dart';
import 'package:property/authentication.dart';
import 'package:property/myproperties.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;


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
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()
        ), // Navigate to the screen with bottom navigation
      );

      // Add setState here to trigger a rebuild after navigation
      setState(() {
        // Update state variables or perform any necessary actions after navigation
      });

    } catch (error) {
      // Handle errors
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

  Widget _bodyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _user != null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_user!.photoURL ?? 'https://cdn-icons-png.flaticon.com/512/700/700674.png'),
              ),
              SizedBox(height: 20),
              Text(
                _user!.displayName ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                _user!.email ?? '',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              const Divider(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyPropertiesPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    // Set the desired background color
                  ),
                  icon: Icon(
                    Icons.home,
                    color: Color(0xFF013c7e),
                  ),
                  label: Text(
                    'My Properties',
                    style: TextStyle(color: Color(0xFF013c7e), fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // SizedBox(height: 5,),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPropertyPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    // Set the desired background color
                  ),
                  icon: Icon(
                    Icons.add,
                    color: Color(0xFF013c7e),
                  ),
                  label: Text(
                    'Add Property',
                    style: TextStyle(color: Color(0xFF013c7e), fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            ],
          )
              : Row(
            children: [
              Icon(
                Icons.person_2_outlined,
                size: 40, // Adjust the size of the icon as needed
                color: Color(0xFF013c7e),
              ),
              SizedBox(width: 10), // Add spacing between the icon and text
              Text(
                'Hello Guest!',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Color(0xFF013c7e)),
              ),
            ],
          ),

          SizedBox(height: 10),
          // Sign-in and Sign-out button
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_user == null) {
                  _handleSignIn();
                } else {
                  _handleSignOut();
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                // Set the desired background color
              ),
              icon: Icon(
                _user == null ? Icons.login : Icons.logout, // Change icons based on sign in/out state
                color: Color(0xFF013c7e),
              ),
              label: Text(
                _user == null ? 'Sign In' : 'Sign Out',
                style: TextStyle(color: Color(0xFF013c7e), fontWeight: FontWeight.bold),
              ),
            ),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Always return false to disable the Android back button
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xFF013c7e),
        ),
        body: _bodyContent(),
      ),
    );
  }
}
