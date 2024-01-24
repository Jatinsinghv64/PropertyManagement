import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property/profile.dart';

class AddPropertyPage extends StatefulWidget {
  @override
  _AddPropertyPageState createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property',
          style: TextStyle(
              color: Colors.white
          ),
        ),
        backgroundColor: const Color(0xFF013c7e),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the profile page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: _AddPropertyForm(),
        ),
      ),
    );
  }
}

class _AddPropertyForm extends StatefulWidget {
  @override
  _AddPropertyFormState createState() => _AddPropertyFormState();
}

class _AddPropertyFormState extends State<_AddPropertyForm> {
  final _formKey = GlobalKey<FormState>();
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
  List<File> _selectedImages = [];
  List<String> bedroomOptions = ['1', '2', '3', '4', '5'];
  String selectedBedroom = '1';
  List<String> propertyTypeOptions = ['Apartments', 'Villa', 'Townhouse', 'Penthouse', 'Duplex'];
  String selectedpropertyType = 'Apartments';
  List<String> bathroomOptions = ['1', '2', '3', '4', '5'];
  String selectedBathroom = '1';
  File? _selectedAgentImage; // New controller for agent image

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }


  Widget _buildDropdown(
      String labelText,
      String value,
      List<String> options,
      void Function(String?)? onChanged,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            items: options.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerButton(String buttonText, Function() onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF013c7e), // Set the background color to green
        fixedSize: Size(200, 50), // Set the width and height as per your requirement
      ),
      child: Text(buttonText,
        style: TextStyle(
            color: Colors.white
        ),
      ),
    );
  }

  Widget _buildSelectedImagesPreview(List<File> images) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(
              images[index],
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickPropertyImages() async {
    List<XFile>? pickedImages = await ImagePicker().pickMultiImage();

    if (pickedImages != null) {
      setState(() {
        _selectedImages = pickedImages.map((image) => File(image.path)).toList();
      });
    }
  }

  Future<void> _pickAgentImage() async {
    try {
      XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        // Upload agent image to Firebase Storage
        String imageName = 'agent_images/${DateTime.now()}.png';
        Reference storageReference = FirebaseStorage.instance.ref().child(imageName);
        UploadTask uploadTask = storageReference.putFile(File(pickedImage.path));

        await uploadTask.whenComplete(() async {
          // Get the download URL for the uploaded image
          String agentImageUrl = await storageReference.getDownloadURL();

          // Update the agentImageUrlController with the URL
          _agentImageUrlController.text = agentImageUrl;

          // Set the selected agent image
          setState(() {
            _selectedAgentImage = File(pickedImage.path);
          });
        });
      }
    } catch (e) {
      // Handle error
      print('Error picking agent image: $e');
    }
  }


  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> imageUrls = [];

    try {
      for (int i = 0; i < images.length; i++) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('property_images/${DateTime.now()}_$i.png');
        UploadTask uploadTask = storageReference.putFile(images[i]);

        await uploadTask.whenComplete(() async {
          String imageUrl = await storageReference.getDownloadURL();
          imageUrls.add(imageUrl);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading images: $e')),
      );
    }

    return imageUrls;
  }

  Future<void> _saveProperty() async {
    try {
      List<String> imageUrls = await _uploadImages(_selectedImages);
      String agentName = _agentNameController.text.trim();
      String agentContact = _agentContactController.text.trim();
      String agentImageUrl = _agentImageUrlController.text.trim();
      String title = _titleController.text.trim();
      String description = _descriptionController.text.trim();
      String location = _locationController.text.trim();
      String availableFrom = _availableFromController.text.trim();
      String propertySize = _propertySizeController.text.trim();
      String agentDetails = _agentDetailsController.text.trim();
      String facilities = _facilitiesController.text.trim();
      String developedBy = _developedByController.text.trim();
      String amenities = _amenitiesController.text.trim();
      String uniquePropertyId = _uniquePropertyIdController.text.trim();
      String bathroom = selectedBathroom;
      String bedrooms = selectedBedroom;
      String propertyType = selectedpropertyType;
      String documentId = title;

      // Save property to Firestore
      await FirebaseFirestore.instance.collection('properties').doc(documentId).set({
        'agentName': agentName,
        'agentContact': agentContact,
        'agentImageUrl': agentImageUrl,
        'title': title,
        'description': description,
        'location': location,
        'propertyType': propertyType,
        'availableFrom': availableFrom,
        'propertySize': propertySize,
        'bathrooms': bathroom,
        'agentDetails': agentDetails,
        'facilities': facilities,
        'developedBy': developedBy,
        'amenities': amenities,
        'uniquePropertyId': uniquePropertyId,
        'bedrooms': bedrooms,
        'imgUrls': imageUrls,
      });

      // Show a snackbar indicating successful property addition
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property added successfully!')),
      );

      // Navigate back to ProfilePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } catch (e) {
      // Handle error when saving property
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding property: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField('Agent Name', _agentNameController),
            _buildTextField('Agent Contact', _agentContactController),
            _buildTextField('Agent Image URL', _agentImageUrlController),
            _buildTextField('Title', _titleController),
            _buildTextField('Description', _descriptionController),
            _buildTextField('Location', _locationController),
            _buildTextField('Available From', _availableFromController),
            _buildTextField('Property Size', _propertySizeController),
            _buildTextField('Agent Details', _agentDetailsController),
            _buildTextField('Facilities', _facilitiesController),
            _buildTextField('Developed By', _developedByController),
            _buildTextField('Amenities', _amenitiesController),
            _buildTextField('Unique Property ID', _uniquePropertyIdController),
            _buildDropdown('Bathrooms', selectedBathroom, bathroomOptions,
                    (value) => setState(() => selectedBathroom = value!)),
            _buildDropdown('Property Type', selectedpropertyType, propertyTypeOptions,
                    (value) => setState(() => selectedpropertyType = value!)),
            _buildDropdown('Bedrooms', selectedBedroom, bedroomOptions,
                    (value) => setState(() => selectedBedroom = value!)),
            _buildImagePickerButton('Add Property Images', _pickPropertyImages),
            _selectedImages.isNotEmpty
                ? _buildSelectedImagesPreview(_selectedImages)
                : SizedBox.shrink(),
            SizedBox(height: 15,),
            _buildImagePickerButton('Add Agent Image', _pickAgentImage),
            _selectedAgentImage != null
                ? Image.file(
              _selectedAgentImage!,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            )
                : SizedBox.shrink(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveProperty();
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Set the background color to green
                fixedSize: Size(200, 50), // Set the width and height as per your requirement
              ),
              child: const Text(
                'Save Property',
                style: TextStyle(fontSize: 18,
                  color: Colors.white,
                ), // Set the font size as per your requirement
              ),
            ),
          ],
        ),
      ),
    );
  }
}