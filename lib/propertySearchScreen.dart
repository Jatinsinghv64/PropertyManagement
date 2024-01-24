import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertySearchScreen extends StatefulWidget {
  @override
  _PropertySearchScreenState createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  String? selectedPropertyType;
  int? selectedBedrooms;
  late Stream<QuerySnapshot> _propertyStream;
  String searchQuery = '';

  void _updatePropertyStream() {
    CollectionReference propertiesCollection =
    FirebaseFirestore.instance.collection('properties');

    Query filteredQuery = propertiesCollection;

    if (selectedPropertyType != null) {
      filteredQuery =
          filteredQuery.where('propertyType', isEqualTo: selectedPropertyType);
    }

    if (selectedBedrooms != null) {
      filteredQuery = filteredQuery.where('bedrooms', isEqualTo: selectedBedrooms);
    }

    if (searchQuery.isNotEmpty) {
      filteredQuery = filteredQuery.where('title', isGreaterThanOrEqualTo: searchQuery);
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
        title: Text('Search and Filter'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by title',
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
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
          ElevatedButton(
            onPressed: () {
              _updatePropertyStream();
            },
            child: Text('Apply Filters'),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _propertyStream,
            builder: (context, snapshot) {
              // Handle the stream data and display search results here
              if (snapshot.hasData) {
                // Your list view or other UI components for displaying results
                return Text('Search Results');
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }
}
