import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:property/loading_screen.dart';
import 'package:property/profile.dart';
import 'package:property/propertycard.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Always return false to disable the Android back button
        return false;
      },
      child: MaterialApp(
        title: 'Real Estate App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home: LoadingScreen(),
        routes: {
          '/home': (context) => PropertyListScreen(),
          '/profile': (context) => ProfilePage(),
        },
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      onTap: onTap,
    );
  }
}
class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PropertyListScreen();
  }
}

class PropertyListScreen extends StatefulWidget {
  @override
  _PropertyListScreenState createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  late Stream<QuerySnapshot> _propertyStream;
  late List<DocumentSnapshot> _properties = [];
  int _selectedIndex = 0;
  late GlobalKey<NavigatorState> _navigatorKey;

  @override
  void initState() {
    super.initState();
    _navigatorKey = GlobalKey<NavigatorState>();
    _propertyStream = FirebaseFirestore.instance.collection('properties').snapshots();
    _properties = [];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('AHB', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white), textAlign: TextAlign.center),
          backgroundColor: Color(0xFF013c7e),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _propertyStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _properties = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: _properties.length,
                        itemBuilder: (context, index) {
                          var property = _properties[index];
                          return PropertyCard(property: property);
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  DateTime? currentBackPressTime;

  Future<bool> _onWillPop() async {
    if (_navigatorKey.currentState?.canPop() ?? false) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      return false;
    } else {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
        currentBackPressTime = now;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Press back again to exit'),
        //   ),
        // );
        return false;
      }
      return true;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      }
    });
  }
}

