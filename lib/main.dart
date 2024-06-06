import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:property/filterpage.dart';
import 'package:property/loading_screen.dart';
import 'package:property/myproperties.dart';
import 'package:property/profile.dart';
import 'package:property/property_detail.dart';
import 'package:property/propertycard.dart';
import 'firebase_options.dart';
import 'dart:async';

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
      home: LoadingScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => MyHomePage(),
        '/profile': (context) => ProfilePage(),
        '/my_properties': (context) => MyPropertiesPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<Widget> bottomBarPages = [
    PropertyListScreen(),
    ProfilePage(),
    MyPropertiesPage(), // Assuming MyPropertiesPage exists
  ];
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> bottomBarPages = [
    PropertyListScreen(),
    ProfilePage(),
    MyPropertiesPage(), // Assuming MyPropertiesPage exists
  ];

  final int initialIndex = 0; // Set the initial index for the bottom bar

  int _currentIndex = 0; // Use a state variable for current index

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex > 0) {
          setState(() {
            _currentIndex--;
          });
          return false; // Prevent app from closing on bottom bar pages
        } else {
          return true; // Allow exiting the app on other pages
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: bottomBarPages,
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
              label:
                  'Settings', // Assuming MyPropertiesPage represents settings
            ),
          ],
          selectedItemColor: Color(0xFF013c7e),
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
  final Map<String, dynamic>? filters; // Make filters nullable

  PropertyListScreen({this.filters});
  @override
  _PropertyListScreenState createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  late TextEditingController minPriceController;
  late TextEditingController maxPriceController;
  bool _priceSliderChanged = false;
  bool _filtersApplied = true;
  bool showFilterBadge = false;
  int filterCount = 0;
  String? selectedPropertyType;
  String? selectedBedrooms;
  String? selectedBathrooms;
  String? selectedLocation;
  double? minPrice;
  String? _selectedSortOption;
  double? maxPrice;
  bool _sliderChanged = false;
  late ValueNotifier<bool> priceSliderChangedNotifier;
  late StreamController<QuerySnapshot> _streamController;

  late Stream<QuerySnapshot> _propertyStream;
  List<DocumentSnapshot> _properties = [];
  String noResultsMessage = '';

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<QuerySnapshot>();
    _propertyStream = _streamController.stream;
    priceSliderChangedNotifier = ValueNotifier<bool>(_priceSliderChanged);
    _updatePropertyStream();
  }

  void _updatePropertyStream() {
    CollectionReference propertiesCollection =
        FirebaseFirestore.instance.collection('properties');

    Query filteredQuery = propertiesCollection;

    if (selectedPropertyType != null) {
      filteredQuery =
          filteredQuery.where('propertyType', isEqualTo: selectedPropertyType);
    }

    if (selectedBedrooms != null) {
      filteredQuery =
          filteredQuery.where('bedrooms', isEqualTo: selectedBedrooms);
    }

    if (selectedBathrooms != null) {
      filteredQuery =
          filteredQuery.where('bathrooms', isEqualTo: selectedBathrooms);
    }

    if (selectedLocation != null) {
      filteredQuery =
          filteredQuery.where('location', isEqualTo: selectedLocation);
    }

    // Apply price range filter
    filteredQuery = filteredQuery
        .where('price', isGreaterThanOrEqualTo: minPrice)
        .where('price', isLessThanOrEqualTo: maxPrice);

    print("Filters: "
        "Location: $selectedLocation, "
        "Property Type: $selectedPropertyType, "
        "Bedrooms: $selectedBedrooms, "
        "Bathrooms: $selectedBathrooms, "
        "Min Price: $minPrice, "
        "Max Price: $maxPrice");

    _propertyStream = filteredQuery.snapshots();

    setState(() {
      showFilterBadge = (_sliderChanged &&
              (selectedLocation != null ||
                  selectedPropertyType != null ||
                  selectedBedrooms != null ||
                  selectedBathrooms != null ||
                  (minPrice != null && minPrice != 0) ||
                  (maxPrice != null && maxPrice != 10000))) &&
          _filtersApplied;

      // Include the notifier in the condition
      filterCount = (selectedLocation != null ? 1 : 0) +
          (selectedPropertyType != null ? 1 : 0) +
          (selectedBedrooms != null ? 1 : 0) +
          (selectedBathrooms != null ? 1 : 0) +
          ((minPrice != null && minPrice != 0) ||
                  (maxPrice != null && maxPrice != 10000)
              ? 1
              : 0);
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF013c7e),
        title: Container(
          padding: EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40.0),
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
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(11.0),
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
              // Filter button with badge
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: Icon(Icons.filter_alt),
                    color: Color(0xFF013c7e),
                    onPressed: () async {
                      final filters = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilterPage(
                            onFiltersApplied: (filters) {
                              setState(() {
                                selectedLocation = filters['location'];
                                selectedPropertyType = filters['propertyType'];
                                selectedBedrooms = filters['bedrooms'];
                                selectedBathrooms = filters['bathrooms'];
                                minPrice =
                                    filters['minPrice']?.toDouble() ?? 0.0;
                                maxPrice =
                                    filters['maxPrice']?.toDouble() ?? 100.0;
                              });
                              _updatePropertyStream();
                            },
                            priceSliderChangedNotifier:
                                priceSliderChangedNotifier,
                            initialLocation: selectedLocation,
                            initialBedrooms: selectedBedrooms,
                            initialBathrooms: selectedBathrooms,
                            initialPropertyType: selectedPropertyType,
                            initialMinPrice: minPrice?.toInt(),
                            initialMaxPrice: maxPrice?.toInt(),
                          ),
                        ),
                      );

                      // Handle any additional logic after filters are applied if needed
                    },
                  ),
                  if (filterCount > 0)
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        filterCount.toString(),
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                ],
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
                    child: Text(noResultsMessage.isEmpty
                        ? 'No properties found'
                        : noResultsMessage),
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
}

class ThirdPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Third Page'),
        backgroundColor: Color(0xFF013c7e),
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
                        rent: property['rent'],
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
