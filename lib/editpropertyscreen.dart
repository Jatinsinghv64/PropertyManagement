import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPropertyScreen extends StatefulWidget {
  final Map<String, dynamic> property;
  final String documentId;
  final VoidCallback refreshCallback;

  EditPropertyScreen({
    required this.property,
    required this.documentId,
    required this.refreshCallback,
  });

  @override
  _EditPropertyScreenState createState() => _EditPropertyScreenState();
}
class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final TextEditingController _agentNameController = TextEditingController();
  final TextEditingController _agentContactController = TextEditingController();
  final TextEditingController _agentImageUrlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _availableFromController = TextEditingController();
  final TextEditingController _propertySizeController = TextEditingController();
  final TextEditingController _agentDetailsController = TextEditingController();
  final TextEditingController _facilitiesController = TextEditingController();
  final TextEditingController _developedByController = TextEditingController();
  final TextEditingController _amenitiesController = TextEditingController();
  final TextEditingController _uniquePropertyIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('EditPropertyScreen documentId: ${widget.documentId}');
    // Initialize controllers with current property data
    _titleController.text = widget.property?['title'] as String? ?? '';
    _locationController.text = widget.property?['location'] as String? ?? '';
    _agentNameController.text = widget.property?['agentName'] as String? ?? '';
    _descriptionController.text = widget.property?['description'] as String? ?? '';
    _propertySizeController.text = widget.property?['propertySize'] as String? ?? '';
    _developedByController.text = widget.property?['developedBy'] as String? ?? '';
    // Initialize other controllers as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Property'),
        backgroundColor: Color(0xFF013c7e),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextFormField(
                controller: _agentNameController,
                decoration: InputDecoration(labelText: 'agentName'),
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: null, // Allow unlimited lines
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Description',
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0), // Adjust the vertical padding as needed
                ),
              ),

              TextFormField(
                controller: _propertySizeController,
                decoration: InputDecoration(labelText: 'propertySize'),
              ),
              // Add other form fields as needed
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Save updates to Firebase
                  _saveUpdates();
                },
                child: Text('Save Updates'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveUpdates() async {
    try {
      // Update property data in Firestore
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(widget.documentId)
          .update({
        'title': _titleController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'agentName' : _agentNameController.text,
        'propertySize' : _propertySizeController.text,
        // Update other fields as needed
      });

      // Call the callback to refresh the property page
      widget.refreshCallback();

      // Navigate back to the previous screen after saving updates
      Navigator.pop(context);
    } catch (error) {
      print('Error updating property: $error');
      // Handle error as needed
    }
  }
}