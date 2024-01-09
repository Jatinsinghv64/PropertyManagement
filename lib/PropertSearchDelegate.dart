import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'main.dart';

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
