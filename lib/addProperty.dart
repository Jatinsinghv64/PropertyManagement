import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPropertyPage extends StatefulWidget {
  @override
  _AddPropertyPageState createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final TextEditingController _agentNameController = TextEditingController();
  final TextEditingController _agentContactController = TextEditingController();
  final TextEditingController _agentImageUrlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _propertyTypeController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _availableFromController = TextEditingController();
  final TextEditingController _propertySizeController = TextEditingController();
  final TextEditingController _bathroomController = TextEditingController();
  final TextEditingController _agentDetailsController = TextEditingController();
  final TextEditingController _facilitiesController = TextEditingController();
  final TextEditingController _developedByController = TextEditingController();
  final TextEditingController _amenitiesController = TextEditingController();
  final TextEditingController _uniquePropertyIdController =
  TextEditingController();

  void _saveProperty() async {
    try {
      await FirebaseFirestore.instance.collection('properties').add({
        'agentName': _agentNameController.text,
        'agentContact': _agentContactController.text,
        'agentImageUrl': _agentImageUrlController.text,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': _imageUrlController.text,
        'location': _locationController.text,
        'propertyType': _propertyTypeController.text,
        'bedrooms': _bedroomsController.text,
        'availableFrom': _availableFromController.text,
        'propertySize': _propertySizeController.text,
        'bathroom': _bathroomController.text,
        'agentDetails': _agentDetailsController.text,
        'facilities': _facilitiesController.text,
        'developedBy': _developedByController.text,
        'amenities': _amenitiesController.text,
        'uniquePropertyId': _uniquePropertyIdController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Property added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding property: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Property'),
        backgroundColor: Color(0xFF013c7e),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _AddPropertyForm(
          agentNameController: _agentNameController,
          agentContactController: _agentContactController,
          agentImageUrlController: _agentImageUrlController,
          titleController: _titleController,
          descriptionController: _descriptionController,
          imageUrlController: _imageUrlController,
          locationController: _locationController,
          propertyTypeController: _propertyTypeController,
          bedroomsController: _bedroomsController,
          availableFromController: _availableFromController,
          propertySizeController: _propertySizeController,
          bathroomController: _bathroomController,
          agentDetailsController: _agentDetailsController,
          facilitiesController: _facilitiesController,
          developedByController: _developedByController,
          amenitiesController: _amenitiesController,
          uniquePropertyIdController: _uniquePropertyIdController,
          onSave: _saveProperty,
        ),
      ),
    );
  }
}

class _AddPropertyForm extends StatelessWidget {
  final TextEditingController agentNameController;
  final TextEditingController agentContactController;
  final TextEditingController agentImageUrlController;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController imageUrlController;
  final TextEditingController locationController;
  final TextEditingController propertyTypeController;
  final TextEditingController bedroomsController;
  final TextEditingController availableFromController;
  final TextEditingController propertySizeController;
  final TextEditingController bathroomController;
  final TextEditingController agentDetailsController;
  final TextEditingController facilitiesController;
  final TextEditingController developedByController;
  final TextEditingController amenitiesController;
  final TextEditingController uniquePropertyIdController;
  final VoidCallback onSave;

  _AddPropertyForm({
    required this.agentNameController,
    required this.agentContactController,
    required this.agentImageUrlController,
    required this.titleController,
    required this.descriptionController,
    required this.imageUrlController,
    required this.locationController,
    required this.propertyTypeController,
    required this.bedroomsController,
    required this.availableFromController,
    required this.propertySizeController,
    required this.bathroomController,
    required this.agentDetailsController,
    required this.facilitiesController,
    required this.developedByController,
    required this.amenitiesController,
    required this.uniquePropertyIdController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Agent Name', agentNameController),
          _buildTextField('Agent Contact', agentContactController),
          _buildTextField('Agent Image URL', agentImageUrlController),
          _buildTextField('Title', titleController),
          _buildTextField('Description', descriptionController),
          _buildTextField('Image URL', imageUrlController),
          _buildTextField('Location', locationController),
          _buildTextField('Property Type', propertyTypeController),
          _buildTextField('Bedrooms', bedroomsController),
          _buildTextField('Available From', availableFromController),
          _buildTextField('Property Size', propertySizeController),
          _buildTextField('Bathroom', bathroomController),
          _buildTextField('Agent Details', agentDetailsController),
          _buildTextField('Facilities', facilitiesController),
          _buildTextField('Developed By', developedByController),
          _buildTextField('Amenities', amenitiesController),
          _buildTextField('Unique Property ID', uniquePropertyIdController),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onSave,
            child: Text('Save Property'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        TextField(controller: controller),
        SizedBox(height: 16),
      ],
    );
  }
}
