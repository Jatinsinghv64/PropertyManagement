import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  final Function(Map<String, String?>) onFiltersApplied;
  final String? initialLocation;
  final String? initialBedrooms;
  final String? initialBathrooms;

  const FilterPage({
    required this.onFiltersApplied,
    this.initialLocation,
    this.initialBedrooms,
    this.initialBathrooms,
  });

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? selectedLocation;
  String? selectedBedrooms;
  String? selectedBathrooms;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialLocation;
    selectedBedrooms = widget.initialBedrooms;
    selectedBathrooms = widget.initialBathrooms;
  }

  void _resetFilters() {
    setState(() {
      selectedLocation = null;
      selectedBedrooms = null;
      selectedBathrooms = null;
    });
    _updatePropertyStream();
  }

  void _updatePropertyStream() {
    widget.onFiltersApplied({
      'location': selectedLocation,
      'bedrooms': selectedBedrooms,
      'bathrooms': selectedBathrooms,
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
            DropdownButton<String>(
              value: selectedLocation,
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
              },
              items: ['Doha', 'Al muntazah', 'Manhattan']
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
            DropdownButton<String>(
              value: selectedBedrooms,
              onChanged: (value) {
                setState(() {
                  selectedBedrooms = value;
                });
              },
              items: ['1', '2', '3', '4', '5+']
                  .map((bedroom) {
                return DropdownMenuItem<String>(
                  value: bedroom,
                  child: Text('$bedroom Bedrooms'),
                );
              })
                  .toList(),
              hint: Text('Select Bedrooms'),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedBathrooms,
              onChanged: (value) {
                setState(() {
                  selectedBathrooms = value;
                });
              },
              items: ['1', '2', '3', '4', '5+']
                  .map((bathroom) {
                return DropdownMenuItem<String>(
                  value: bathroom,
                  child: Text('$bathroom Bathrooms'),
                );
              })
                  .toList(),
              hint: Text('Select Bathrooms'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _updatePropertyStream();
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
