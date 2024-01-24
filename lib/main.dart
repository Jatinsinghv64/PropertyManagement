import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:property/bottomnavigationBar.dart';
import 'package:property/loading_screen.dart';
import 'package:property/profile.dart';
import 'package:property/property_detail.dart';
import 'package:property/propertycard.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => PropertyListScreen(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            Navigator(
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => PropertyListScreen(),
                );
              },
            ),
            Navigator(
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                );
              },
            ),
            Navigator(
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => ThirdPage(),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Third',
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthenticationWrapper(),
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
  String? selectedPropertyType;
  int? selectedBedrooms;
  late Stream<QuerySnapshot> _propertyStream;
  List<DocumentSnapshot> _properties = [];
  String noResultsMessage = '';

  @override
  void initState() {
    super.initState();
    _updatePropertyStream();
  }

  void _updatePropertyStream() {
    CollectionReference propertiesCollection =
    FirebaseFirestore.instance.collection('properties');

    Query filteredQuery = propertiesCollection;

    if (selectedPropertyType != null) {
      filteredQuery = filteredQuery
          .where('propertyType', isEqualTo: selectedPropertyType);
    }

    if (selectedBedrooms != null) {
      filteredQuery = filteredQuery
          .where('bedrooms', isEqualTo: selectedBedrooms);
    }

    _propertyStream = filteredQuery.snapshots();

    // Add this line to force the rebuild of the widget tree
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF013c7e),
        title: Container(
          padding: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: PropertySearchDelegate(),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF013c7e)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.search,
                            color: Color(0xFF013c7e),
                          ),
                        ),
                        Text(
                          'Building, area',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xFF013c7e),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.filter_list, color: Color(0xFF013c7e)),
                onPressed: () {
                  _showFilterDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _propertyStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _properties = snapshot.data!.docs;
            return _properties.isNotEmpty
                ? ListView.builder(
              itemCount: _properties.length,
              itemBuilder: (BuildContext context, int index) {
                var property = _properties[index];
                return PropertyCard(property: property);
              },
            )
                : Center(
              child: Text(
                  noResultsMessage.isEmpty ? 'No properties found' : noResultsMessage),
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
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Properties'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: Text('Select Property Type'),
                value: selectedPropertyType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPropertyType = newValue;
                  });
                },
                items: <String>['Townhouse', 'Villa', 'Penthouse']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButton<int>(
                hint: Text('Select Number of Bedrooms'),
                value: selectedBedrooms,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedBedrooms = newValue;
                  });
                },
                items: <int>[1, 2, 3, 4, 5]
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _applyFilters();
                Navigator.of(context).pop();
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                _clearFilters();
                Navigator.of(context).pop();
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _applyFilters() {
    _updatePropertyStream();
  }

  void _clearFilters() {
    selectedPropertyType = null;
    selectedBedrooms = null;
    _updatePropertyStream();
  }
}

class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Third Page'),
      ),
      body: Center(
        child: Text('Third Page'),
      ),
    );
  }
}

class PropertySearchDelegate extends SearchDelegate<String> {
  final Stream<QuerySnapshot> propertyStream =
  FirebaseFirestore.instance.collection('properties').snapshots();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: propertyStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<DocumentSnapshot> properties = snapshot.data!.docs;
          final List<DocumentSnapshot> searchResults = properties
              .where((property) =>
          property['title']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ||
              property['location']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();

          return ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              var property = searchResults[index];
              return ListTile(
                title: Text(
                  property['title'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  property['location'],
                  style: TextStyle(fontSize: 16),
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    property['imgUrls'][0],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                onTap: () {
                  // Navigate to PropertyDetailsPage with the selected property
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyDetailsPage(
                        title: property['title'],
                        description: property['description'],
                        imgUrls: property['imgUrls'],
                        location: property['location'],
                        propertyType: property['propertyType'],
                        bedrooms: property['bedrooms'],
                        facilities: property['facilities'],
                        availableFrom: property['availableFrom'],
                        propertySize: property['propertySize'],
                        bathrooms: property['bathrooms'],
                        agentDetails: property['agentDetails'],
                        amenities: property['amenities'],
                        developedBy: property['developedBy'],
                        uniquePropertyId: property['uniquePropertyId'],
                        agentName: property['agentName'],
                        agentContact: property['agentContact'],
                        agentImageUrl: property['agentImageUrl'],
                      ),
                    ),
                  );
                },
              );
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
    );
  }




  @override
  Widget buildSuggestions(BuildContext context) {
    // You can implement search suggestions here if needed
    return Center(
      child: Text('Search Suggestions for: $query'),
    );
  }
}