import 'dart:core';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:property/loading_screen.dart';
import 'package:property/profile.dart';
import 'package:property/property_detail.dart';
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
        // If the current screen is not the home screen (index 0),
        // navigate to the home screen and prevent going back
        if (navigatorKey.currentState?.canPop() ?? false) {
          navigatorKey.currentState?.popUntil((route) => route.isFirst);
          return false;
        }
        // Otherwise, allow the back button to work as usual
        return true;
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
  late List<DocumentSnapshot> _properties = []; // Initialize _properties here
  int _selectedIndex = 0;
  late GlobalKey<NavigatorState> _navigatorKey;
  PropertyFilterOptions _filterOptions = PropertyFilterOptions();
  List<DocumentSnapshot> _filteredProperties = [];

  @override
  void initState() {
    super.initState();
    _navigatorKey = GlobalKey<NavigatorState>();
    _propertyStream = FirebaseFirestore.instance.collection('properties').snapshots();

    // Initialize _properties with an empty list
    _properties = [];
  }

  List<DocumentSnapshot> _filterProperties(String query) {
    query = query.toLowerCase();

    List<DocumentSnapshot> filteredProperties = _properties.where((property) {
      final title = property['title'].toString().toLowerCase();
      final location = property['location'].toString().toLowerCase();
      final propertyType = property['propertyType'].toString().toLowerCase();
      final bedrooms = property['bedrooms'].toString();

      return (title.contains(query) ||
          location.contains(query) ||
          propertyType.contains(query) ||
          bedrooms.contains(query)) &&
          (!_filterOptions.hasFilters() ||
              (property['propertyType'] == _filterOptions.propertyType &&
                  property['price'] >= _filterOptions.minPrice &&
                  property['price'] <= _filterOptions.maxPrice &&
                  property['bedrooms'] >= _filterOptions.minBeds &&
                  property['bathrooms'] >= _filterOptions.minBaths &&
                  (property['amenities'] as List<dynamic>)
                      .contains(_filterOptions.selectedAmenity)));
          }).toList();
    setState(() {
      _properties = filteredProperties;
    });

    return filteredProperties;
  }


  Widget _buildFilterOptions() {
    // Extract unique property types from the properties list
    Set<String> uniquePropertyTypes = _properties
        .map<String>((property) => property['propertyType'].toString())
        .toSet();

    return Column(
      children: [
        DropdownButton<String>(
          value: _filterOptions.propertyType,
          onChanged: (newValue) {
            setState(() {
              _filterOptions.propertyType = newValue!;
            });
          },
          items: uniquePropertyTypes
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          hint: Text('Select Property Type'),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('AHB', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          backgroundColor: Color(0xFF013c7e),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    _filteredProperties = _properties
                        .where((property) =>
                    property['location'].toString().toLowerCase().contains(value.toLowerCase()) ||
                        property['propertyType'].toString().toLowerCase().contains(value.toLowerCase()) ||
                        property['bedrooms'].toString().contains(value))
                        .toList();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => _buildFilterOptions(),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: _buildPropertiesList(),
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

  Future<bool> _onWillPop() async {
    // If the current screen is not the home screen (index 0),
    // navigate to the home screen and prevent going back
    if (_navigatorKey.currentState?.canPop() ?? false) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      return false;
    }
    // Otherwise, allow the back button to work as usual
    return true;
  }
  Widget _buildPropertiesList() {
    final List<DocumentSnapshot> displayedProperties = _filteredProperties.isNotEmpty
        ? _filteredProperties
        : _properties;

    return StreamBuilder<QuerySnapshot>(
      stream: _propertyStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _properties = snapshot.data!.docs;

          return ListView.builder(
            itemCount: displayedProperties.length,
            itemBuilder: (context, index) {
              var property = displayedProperties[index];
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
    );
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
class PropertySearchDelegate extends SearchDelegate<String> {
  final List<DocumentSnapshot> properties;
  final PropertyFilterOptions filterOptions;

  PropertySearchDelegate(this.properties, this.filterOptions);

  late List<DocumentSnapshot> _filteredProperties;

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
    _filterProperties();
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _filterProperties();
    return _buildSearchResults();
  }

  void _filterProperties() {
    _filteredProperties = properties.where((property) {
      final title = property['title'].toString().toLowerCase();
      final location = property['location'].toString().toLowerCase();
      return (title.contains(query.toLowerCase()) || location.contains(query.toLowerCase())) &&
          (!filterOptions.hasFilters() ||
              (property['propertyType'] == filterOptions.propertyType &&
                  property['bedrooms'] >= filterOptions.minBeds));
    }).toList();
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _filteredProperties.length,
      itemBuilder: (context, index) {
        var property = _filteredProperties[index];
        return ListTile(
          title: Text(property['title']),
          subtitle: Text(property['location']),
          onTap: () {
            close(context, property.id);
          },
        );
      },
    );
  }
}

class PropertyCard extends StatelessWidget {
  final DocumentSnapshot property;

  PropertyCard({required this.property});
  void _showPropertyDetails(BuildContext context) {
    List<String> imgUrls = List<String>.from(property['imgUrls']);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(
          title: property['title'],
          description: property['description'],
          imageUrl: property['imageUrl'],
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
            agentName: property['agentName'], // Replace with actual agent name
            agentContact: property['agentContact'], // Replace with actual agent contact details
            agentImageUrl: property['agentImageUrl']
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> imgUrls = List<String>.from(property['imgUrls']);

    return InkWell(
      onTap: () => _showPropertyDetails(context),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                enableInfiniteScroll: true,
                autoPlay: true,
              ),
              items: imgUrls.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    );
                  },
                );
              }).toList(),
            ),
            ListTile(
              title: Text(property['title']),
              subtitle: Text(property['location']),
            ),
          ],
        ),
      ),
    );
  }
}

// Add this class for filter options
class PropertyFilterOptions {
  String propertyType = "";
  double minPrice = 0.0;
  double maxPrice = double.infinity;
  int minBeds = 0;
  int minBaths = 0;
  String selectedAmenity = "";

  bool hasFilters() {
    return propertyType.isNotEmpty ||
        minPrice > 0.0 ||
        maxPrice < double.infinity ||
        minBeds > 0 ||
        minBaths > 0 ||
        selectedAmenity.isNotEmpty;
  }
}



