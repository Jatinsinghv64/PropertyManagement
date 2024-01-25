import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:property/editpropertyscreen.dart';

class MyPropertiesPage extends StatefulWidget {
  @override
  _MyPropertiesPageState createState() => _MyPropertiesPageState();
}

class _MyPropertiesPageState extends State<MyPropertiesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF013c7e),
        title: Text('My Properties'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.popUntil(context, ModalRoute.withName('/profile'));
            } else {
              // Handle the case when there are no routes to pop
              // You might want to navigate to the profile page directly in this case
              Navigator.pushReplacementNamed(context, '/profile');
            }
          },
        ),

      ),
      body: FutureBuilder(
        future: _getUserProperties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<DocumentSnapshot> properties = snapshot.data as List<DocumentSnapshot>;

            if (properties.isEmpty) {
              return Center(
                child: Text('No properties found for the current user.'),
              );
            }

            return ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> property = properties[index].data() as Map<String, dynamic>;

                // Display property details here
                return ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      property['imgUrls'][0],
                      width: 100, // Adjust the width as needed
                      height: 100, // Adjust the height as needed
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(property['title'] ?? 'Property Name N/A'),
                  subtitle: Text(property['location'] ?? 'Location N/A'),
                  // Add more fields as needed
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Handle edit action
                          _editProperty(context, snapshot.data![index]);

                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Handle delete action
                          _deleteProperty(property);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
  void refreshPropertyData() {
    // Call the function to fetch the updated data (e.g., _getUserProperties())
    // Set the state to trigger a rebuild of the widget
    setState(() {
      // Update state variables or perform any necessary actions
    });
  }
  Future<List<DocumentSnapshot>> _getUserProperties() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String userEmail = user.email ?? '';

      try {
        // Query properties collection based on agentEmail
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('properties')
            .where('agentEmail', isEqualTo: userEmail)
            .get();

        return querySnapshot.docs;
      } catch (error) {
        print("Error querying properties: $error");
        return []; // Return an empty list or handle the error as needed
      }
    } else {
      print("User is not authenticated");
      return []; // Return an empty list or handle the case where the user is not authenticated
    }
  }

  void _editProperty(BuildContext context, DocumentSnapshot propertySnapshot) {
    String documentId = propertySnapshot.id;
    Map<String, dynamic> property = propertySnapshot.data() as Map<String, dynamic>;

    // When navigating to EditPropertyScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPropertyScreen(
          property: property,
          documentId: documentId,
          refreshCallback: refreshPropertyData, // Pass the callback
        ),
      ),
    ).then((result) {
      // Handle the result if needed
      if (result != null) {
        print('Result: $result');
      }
    });
  }

  void _deleteProperty(Map<String, dynamic> propertyData) {
    // Implement the logic for deleting the property
    // You can show a confirmation dialog and delete the property if confirmed
    print('Delete property: ${propertyData['title']}');
  }
}
