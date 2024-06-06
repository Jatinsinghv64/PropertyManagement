import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class FilterPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersApplied;
  final String? initialLocation;
  final String? initialBedrooms;
  final String? initialBathrooms;
  final String? initialPropertyType;
  final int? initialMinPrice;
  final int? initialMaxPrice;
  final ValueNotifier<bool> priceSliderChangedNotifier;

  const FilterPage({
    required this.onFiltersApplied,
    required this.priceSliderChangedNotifier,
    this.initialLocation,
    this.initialBedrooms,
    this.initialBathrooms,
    this.initialPropertyType,
    this.initialMinPrice,
    this.initialMaxPrice,
  });

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String? selectedLocation;
  String? selectedBedrooms;
  String? selectedBathrooms;
  String? selectedPropertyType;
  double minPrice = 0.0;
  double maxPrice = 10000.0;
  bool _sliderChanged = true;
  bool _initialSliderState = true;
  late ValueNotifier<bool> _priceSliderChangedNotifier;
  AutoCompleteTextField<String>? locationTextField;
  GlobalKey<AutoCompleteTextFieldState<String>> locationKey = GlobalKey();
  String sortOption = 'none';

  //
  // bool _priceSliderChanged = false;
  // late ValueNotifier<bool> _priceSliderChangedNotifier;
  // final ValueNotifier<bool> priceSliderChangedNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialLocation;
    selectedBedrooms = widget.initialBedrooms;
    selectedBathrooms = widget.initialBathrooms;
    selectedPropertyType = widget.initialPropertyType;
    minPrice = widget.initialMinPrice?.toDouble() ?? 0.0;
    maxPrice = widget.initialMaxPrice?.toDouble() ?? 10000.0;
    _priceSliderChangedNotifier = widget.priceSliderChangedNotifier;
    // _priceSliderChangedNotifier = ValueNotifier<bool>(true);
  }

  void _resetFilters() {
    setState(() {
      selectedLocation = null;
      selectedBedrooms = null;
      selectedBathrooms = null;
      selectedPropertyType = null;
      minPrice = 0.0;
      maxPrice = 10000.0;
      // _initialSliderState = true; // Set _initialSliderState to true when resetting filters
    });
    _updatePropertyStream();
  }

  List<String> propertyTypes = ['Apartment', 'House', 'Villa', 'bedroom'];

  void _updatePropertyStream() {
    widget.priceSliderChangedNotifier.value = true;
    widget.onFiltersApplied({
      'location': selectedLocation,
      'bedrooms': selectedBedrooms,
      'bathrooms': selectedBathrooms,
      'propertyType': selectedPropertyType,
      'minPrice': minPrice.toInt(),
      'maxPrice': maxPrice.toInt(),
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filters'),
        backgroundColor: Color(0xFF013c7e),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Locality',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF013c7e),
                ),
              ),
              AutoCompleteTextField<String>(
                key: locationKey,
                clearOnSubmit: false,
                controller: TextEditingController(text: selectedLocation), // Set the initial value
                suggestions: ['Doha', 'Al muntazah', 'Manhattan', 'Hells kitchen', 'Gotham City'],
                decoration: InputDecoration(
                  hintText: 'Search in a City, Locality',
                ),
                itemBuilder: (BuildContext context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                itemSorter: (String a, String b) {
                  return a.compareTo(b);
                },
                itemFilter: (String suggestion, String query) {
                  return suggestion.toLowerCase().contains(query.toLowerCase());
                },
                itemSubmitted: (String value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
                textSubmitted: (String value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Number of Bedrooms',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF013c7e),
                    ),
                  ),
                  Wrap(
                    spacing:
                        8.0, // Adjust the spacing between buttons as needed
                    children: ['1', '2', '3', '4', '5'].map((bedroom) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: bedroom == selectedBedrooms
                              ? Color(0xFF013c7e)
                              : Colors.white,
                          onPrimary: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedBedrooms =
                                bedroom == selectedBedrooms ? null : bedroom;
                          });
                        },
                        child: Text(
                          '$bedroom Bedrooms',
                          style: TextStyle(
                            color: bedroom == selectedBedrooms
                                ? Colors.white
                                : Color(0xFF013c7e),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Number of Bathrooms',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF013c7e),
                    ),
                  ),
                  Wrap(
                    spacing:
                        8.0, // Adjust the spacing between buttons as needed
                    children: ['1', '2', '3', '4', '5'].map((bathroom) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: bathroom == selectedBathrooms
                              ? Color(0xFF013c7e)
                              : Colors.white,
                          onPrimary: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedBathrooms =
                                bathroom == selectedBathrooms ? null : bathroom;
                          });
                        },
                        child: Text(
                          '$bathroom Bathrooms',
                          style: TextStyle(
                            color: bathroom == selectedBathrooms
                                ? Colors.white
                                : Color(0xFF013c7e),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Property Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF013c7e),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (Map<String, dynamic> propertyType in [
                              {'type': 'Apartment', 'icon': Icons.apartment},
                              {'type': 'House', 'icon': Icons.house},
                              {'type': 'Villa', 'icon': Icons.location_city},
                              {'type': 'bedroom', 'icon': Icons.king_bed},
                              {'type': 'Townhouse', 'icon': Icons.home_filled},
                            ])
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: propertyType['type'] ==
                                            selectedPropertyType
                                        ? Color(0xFF013c7e)
                                        : Colors.white,
                                    onPrimary: Colors.white,
                                    minimumSize: Size(
                                        100, 100), // Equal size for all boxes
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedPropertyType =
                                          propertyType['type'] ==
                                                  selectedPropertyType
                                              ? null
                                              : propertyType['type'];
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(propertyType['icon'],
                                          size: 30,
                                          color: propertyType['type'] ==
                                                  selectedPropertyType
                                              ? Colors.white
                                              : Color(0xFF013c7e)),
                                      SizedBox(height: 8),
                                      Text(
                                        propertyType['type'],
                                        style: TextStyle(
                                          color: propertyType['type'] ==
                                                  selectedPropertyType
                                              ? Colors.white
                                              : Color(0xFF013c7e),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 20),
              SizedBox(height: 20),
              Text(
                'Price Range: ${minPrice.toInt()} QAR/Year - ${maxPrice.toInt()} QAR/Year',
                style: TextStyle(
                    color: Color(0xFF013c7e), fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onPanDown: (_) {
                  // User started interacting with the slider
                  setState(() {
                    _initialSliderState = false;
                  });
                },
                child: RangeSlider(
                  values: RangeValues(minPrice, maxPrice),
                  min: 0.0,
                  max: 10000.0,
                  onChanged: (values) {
                    setState(() {
                      minPrice = values.start;
                      maxPrice = values.end;
                      _sliderChanged = true;
                    });
                  },
                  activeColor: Color(
                      0xFF013c7e), // Set the color when the slider is active (user is sliding)
                  inactiveColor: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.onFiltersApplied({
                    'location': selectedLocation,
                    'bedrooms': selectedBedrooms,
                    'bathrooms': selectedBathrooms,
                    'propertyType': selectedPropertyType,
                    'minPrice': minPrice.toInt(),
                    'maxPrice': maxPrice.toInt(),
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
      ),
    );
  }
}
