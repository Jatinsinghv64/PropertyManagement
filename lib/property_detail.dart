import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'mapBox.dart';

class PropertyDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String location;

  PropertyDetailsPage({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 600,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // Navigate to Google Maps or perform other actions

                      Navigator.push(context, MaterialPageRoute(builder: (context) => MapBoxScreen()));
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Text(
                          location,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(description),
                  // Include the Google Maps widget here
                  // Container(
                  //   height: 200, // Set the height of the map container
                  //   child: GoogleMap(
                  //     initialCameraPosition: CameraPosition(
                  //       target: LatLng(0.0, 0.0), // Set initial map coordinates
                  //       zoom: 14.0, // Set initial zoom level
                  //     ),
                  //     markers: Set<Marker>.from([
                  //       Marker(
                  //         markerId: MarkerId('property_location'),
                  //         position: LatLng(0.0, 0.0), // Set the coordinates of the property location
                  //         infoWindow: InfoWindow(title: title),
                  //       ),
                  //     ]),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
