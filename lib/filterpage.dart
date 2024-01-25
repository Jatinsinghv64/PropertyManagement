// FilterPage.dart
import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  final Function(Map<String, String?>) onFiltersApplied;
  final String? initialLocation;

  const FilterPage({
    required this.onFiltersApplied,
    this.initialLocation,
  });

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? selectedLocation;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialLocation;
  }

  void _resetFilters() {
    setState(() {
      selectedLocation = null; // Clear all filters
    });
    _updatePropertyStream(); // Fetch all properties
  }

  void _updatePropertyStream() {
    // Call this method to update the property stream and fetch all properties
    widget.onFiltersApplied({
      'location': selectedLocation,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filters'),
        backgroundColor: Color(0xFF013c7e),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown for location
            DropdownButton<String>(
              value: selectedLocation,
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
              },
              items: ['Doha']
                  .map((location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                );
              })
                  .toList(),
              hint: Text('Select Location'),
            ),
            SizedBox(height: 20),
            // Apply Filters button
            ElevatedButton(
              onPressed: () {
                widget.onFiltersApplied({
                  'location': selectedLocation,
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF013c7e),
              ),
              child: Text(
                'Apply Filters',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            // Reset Filters button
            TextButton(
              onPressed: _resetFilters,
              child: Text(
                'Reset Filters',
                style: TextStyle(
                  color: Color(0xFF013c7e),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
