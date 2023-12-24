import 'dart:core';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
    return MaterialApp(
      title: 'Real Estate App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: AuthenticationWrapper(),
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
  late List<DocumentSnapshot> _properties;

  @override
  void initState() {
    super.initState();
    _propertyStream =
        FirebaseFirestore.instance.collection('properties').snapshots();
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
          SnackBar(content: Text('Property added successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding property: $e')));
    }
  }

  List<Map<String, String>> _filterProperties(String query) {
    return _properties.where((property) {
      final title = property['title'].toString().toLowerCase();
      final location = property['location'].toString().toLowerCase();
      return title.contains(query) || location.contains(query);
    }).map((property) {
      return {
        'title': property['title'].toString(),
        'location': property['location'].toString(),
      };
    }).toList();
  }

  void _showSearchPage(BuildContext context) async {
    final String? selected = await showSearch<String>(
      context: context,
      delegate: PropertySearchDelegate(_properties),
    );

    if (selected != null) {
      _navigateToPropertyDetails(selected);
    }
  }

  void _navigateToPropertyDetails(String propertyId) {
    var selectedProperty =
        _properties.firstWhere((property) => property.id == propertyId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(
          title: selectedProperty['title'],
          description: selectedProperty['description'],
          imageUrl: selectedProperty['imageUrl'],
          location: selectedProperty['location'],
          propertyType: selectedProperty['propertyType'],
          bedrooms: selectedProperty['bedrooms'],
          facilities: selectedProperty['facilities'],
          availableFrom: selectedProperty['availableFrom'],
          propertySize: selectedProperty['propertySize'],
          bathroom: selectedProperty['bathroom'],
          agentDetails: selectedProperty['agentDetails'],
          amenities: selectedProperty['amenities'],
          developedBy: selectedProperty['developedBy'],
          uniquePropertyId: selectedProperty['uniquePropertyId'],
            agentName: selectedProperty['agentName'], // Replace with actual agent name
            agentContact: selectedProperty['agentContact'], // Replace with actual agent contact details
            agentImageUrl: selectedProperty['agentImageUrl']
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Properties'),
        backgroundColor: Color(0xFF013c7e),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchPage(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white, // Set the drawer header color to white
              ),
                child: Image.asset(
                  '/Users/jatinsingh/StudioProjects/property/assets/Images/AHBLOGO.jpg', // Adjust the path accordingly
                  // fit: BoxFit.cover,
                ),
            ),
            ListTile(
              title: Text('Profile',style: TextStyle(color: Color(0xFF013c7e)),),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              title: Text('Settings',style: TextStyle(color: Color(0xFF013c7e)),),
              onTap: () {
                // Handle Settings navigation
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
    );
  }
}

class PropertySearchDelegate extends SearchDelegate<String> {
  final List<DocumentSnapshot> properties;

  PropertySearchDelegate(this.properties);

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
    final filteredProperties =
        query.isEmpty ? properties : _filterProperties(query);

    return ListView.builder(
      itemCount: filteredProperties.length,
      itemBuilder: (context, index) {
        var property = filteredProperties[index];
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

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredProperties =
        query.isEmpty ? properties : _filterProperties(query);

    return ListView.builder(
      itemCount: filteredProperties.length,
      itemBuilder: (context, index) {
        var property = filteredProperties[index];
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

  List<DocumentSnapshot> _filterProperties(String query) {
    return properties.where((property) {
      final title = property['title'].toString().toLowerCase();
      final location = property['location'].toString().toLowerCase();
      return title.contains(query) || location.contains(query);
    }).toList();
  }
}

class AddPropertyForm extends StatefulWidget {
  final Function(String, String, String) onAddProperty;

  AddPropertyForm({required this.onAddProperty});

  @override
  _AddPropertyFormState createState() => _AddPropertyFormState();
}

class _AddPropertyFormState extends State<AddPropertyForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Property'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(labelText: 'Location'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onAddProperty(
              _titleController.text,
              _descriptionController.text,
              _locationController.text,
            );
            Navigator.pop(context);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class PropertyCard extends StatelessWidget {
  final DocumentSnapshot property;

  PropertyCard({required this.property});

  void _showPropertyDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(
          title: property['title'],
          description: property['description'],
          imageUrl: property['imageUrl'],
          location: property['location'],
          propertyType: property['propertyType'],
          bedrooms: property['bedrooms'],
          facilities: property['facilities'],
          availableFrom: property['availableFrom'],
          propertySize: property['propertySize'],
          bathroom: property['bathroom'],
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
    return InkWell(
      onTap: () => _showPropertyDetails(context),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Image.network(
              property['imageUrl'] ?? 'https://via.placeholder.com/350', // Provide a default URL if 'imageUrl' is null
              height: 350,
              width: double.infinity,
              fit: BoxFit.cover,
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
