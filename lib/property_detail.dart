import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PropertyDetailsPage extends StatelessWidget {
  final String agentName;
  final String agentContact;
  final String agentImageUrl;
  final String title;
  final String description;
  final String location;
  final String propertyType;
  final String bedrooms;
  final String availableFrom;
  final String propertySize;
  final String bathrooms;
  final String agentDetails;
  final String facilities;
  final String developedBy;
  final String amenities;
  final String uniquePropertyId;
  final List<dynamic> imgUrls;
  PropertyDetailsPage(
      {required this.title,
      required this.description,
      required this.location,
      required this.propertyType,
      required this.bedrooms,
      required this.availableFrom,
      required this.propertySize,
      required this.bathrooms,
      required this.agentDetails,
      required this.facilities,
      required this.developedBy,
      required this.amenities,
      required this.uniquePropertyId,
      required this.agentName,
      required this.agentContact,
      required this.agentImageUrl,
      required this.imgUrls});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Details'),
        backgroundColor: Color(0xFF013c7e),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 16,
            ),
            // Carousel for multiple images
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.6,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.9,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                ),
                items: imgUrls.map((imageUrl) {
                  return CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 50.0,  // Set the width as needed
                      height: 50.0, // Set the height as needed
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0, // Set the stroke width as needed
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    imageBuilder: (context, imageProvider) => Image(
                      image: imageProvider,
                      errorBuilder: (context, error, stackTrace) {
                        print("Error loading image: $error");
                        return Icon(Icons.error);
                      },
                    ),
                  );
                }).toList(),
              ),
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
                      color: Color(0xFF013c7e),
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF013c7e),
                        ),
                        SizedBox(width: 8),
                        Text(
                          location,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF013c7e),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF013c7e)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        buildRow(propertyType, 'Property Type', 12),
                        buildRow(bedrooms, 'Bedrooms', 12),
                        buildRow(availableFrom, 'Available From', 12),
                        buildRow(propertySize, 'Property Size', 12),
                        buildRow(bathrooms, 'Bathroom', 12),
                        buildRow(agentDetails, 'Agent Details', 12),
                        buildRow(facilities, 'Facilities', 12),
                        buildRow(developedBy, 'Developed By', 12),
                        // Add more rows as needed
                      ],
                    ),
                  ),


                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: Color(0xFF013c7e),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF013c7e)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF013c7e),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Amenities',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: Color(0xFF013c7e),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF013c7e)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              amenityTile('Furnished', Icons.chair),
                              amenityTile('Balcony', Icons.balcony),
                              amenityTile('Built in Wardrobes', Icons.check),
                              amenityTile('Central A/C', Icons.ac_unit),
                              amenityTile("Children's Play Area",
                                  Icons.sports_basketball),
                              amenityTile('Concierge', Icons.check),
                              amenityTile('Covered Parking', Icons.car_repair),
                              amenityTile(
                                  'Kitchen Appliances', Icons.soup_kitchen),
                              amenityTile('Lobby in Building',
                                  Icons.maps_home_work_rounded),
                              amenityTile('Security', Icons.security),
                              amenityTile(
                                  'Shared Gym', Icons.sports_gymnastics),
                              amenityTile('Shared Pool', Icons.pool),
                              amenityTile('View of Landmark', Icons.check),
                              amenityTile('View of Water', Icons.water),
                              amenityTile(
                                  'Walk-in Closet', Icons.kitchen_sharp),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Agent',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF013c7e),
                    ),
                  ),
                  AgentDetailsBox(
                    agentName: agentName, // Replace with actual agent name
                    agentContact:
                        agentContact, // Replace with actual agent contact details
                    agentImageUrl: agentImageUrl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildRow(String value, String label, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label + ':',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                value,
                style: TextStyle(fontSize: fontSize, color: Color(0xFF013c7e)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget amenityTile(String amenity, IconData icon) {
  return ListTile(
    contentPadding: EdgeInsets.all(0),
    leading: Icon(
      icon,
      color: Color(0xFF013c7e),
    ),
    title: Text(
      amenity,
      style: TextStyle(
        fontSize: 20,
        color: Color(0xFF013c7e),
      ),
    ),
  );
}

class AgentDetailsBox extends StatelessWidget {
  final String agentName;
  final String agentContact;
  final String agentImageUrl;

  AgentDetailsBox({
    required this.agentName,
    required this.agentContact,
    required this.agentImageUrl,
  });

  // Function to handle agent call
  void _callAgent(String agentContact) async {
    final Uri _phoneLaunchUri = Uri(
      scheme: 'tel',
      path: agentContact,
    );

    if (await canLaunch(_phoneLaunchUri.toString())) {
      await launch(_phoneLaunchUri.toString());
    } else {
      // Handle error
      print('Could not launch $_phoneLaunchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF013c7e), width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Image
          CircleAvatar(
            radius: 50,
            backgroundImage:
                NetworkImage(agentImageUrl), // Add actual agent image URL
          ),
          SizedBox(height: 16),

          // Agent Name
          Text(
            agentName,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF013c7e)),
          ),
          SizedBox(height: 8),

          // Agent Contact Details
          Text(
            agentContact,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          // Call Agent Button
          SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: () {
                _callAgent(agentContact);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Set button color to green
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16), // Set button padding
              ),
              icon: Icon(Icons.phone, size: 24), // Add phone icon
              label: Text(
                'Call Agent',
                style: TextStyle(
                  fontSize: 22, // Set button text size
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
