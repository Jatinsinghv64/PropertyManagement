import 'package:flutter/material.dart';

class FilterOptionsDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;

  FilterOptionsDialog({required this.onApply});

  @override
  _FilterOptionsDialogState createState() => _FilterOptionsDialogState();
}

class _FilterOptionsDialogState extends State<FilterOptionsDialog> {
  String? _selectedPropertyType;
  double _selectedPriceRange = 0.0;
  int _selectedBedrooms = 0;
  int _selectedBathrooms = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Options',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('Property Type:'),
          DropdownButton<String>(
            value: _selectedPropertyType,
            onChanged: (value) {
              setState(() {
                _selectedPropertyType = value;
              });
            },
            items: ['Apartment', 'Villa', 'Penthouse', 'Townhouse']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Text('Price Range:'),
          Slider(
            value: _selectedPriceRange,
            onChanged: (value) {
              setState(() {
                _selectedPriceRange = value;
              });
            },
            min: 0,
            max: 1000000, // Adjust the max value as needed
            divisions: 100,
            label: _selectedPriceRange.round().toString(),
          ),
          Text('QAR ${_selectedPriceRange.round()}'),
          SizedBox(height: 16),
          Text('Bedrooms: $_selectedBedrooms'),
          Slider(
            value: _selectedBedrooms.toDouble(),
            onChanged: (value) {
              setState(() {
                _selectedBedrooms = value.round();
              });
            },
            min: 0,
            max: 7,
            divisions: 7,
            label: _selectedBedrooms.toString(),
          ),
          SizedBox(height: 16),
          Text('Bathrooms: $_selectedBathrooms'),
          Slider(
            value: _selectedBathrooms.toDouble(),
            onChanged: (value) {
              setState(() {
                _selectedBathrooms = value.round();
              });
            },
            min: 0,
            max: 7,
            divisions: 7,
            label: _selectedBathrooms.toString(),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onApply({
                'propertyType': _selectedPropertyType,
                'priceRange': _selectedPriceRange,
                'bedrooms': _selectedBedrooms,
                'bathrooms': _selectedBathrooms,
              });
            },
            child: Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
