import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:property/property_detail.dart';

class PropertyCard extends StatelessWidget {
  final DocumentSnapshot property;

  PropertyCard({required this.property});
  void _showPropertyDetails(BuildContext context) {
    List<String> imgUrls = List<String>.from(property['imgUrls']);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(
            title: property['title'],
            rent: property['rent'],
            description: property['description'],
            imgUrls: property['imgUrls'],
            location: property['location'],
            propertyType: property['propertyType'],
            bedrooms: property['bedrooms'],
            facilities: property['facilities'],
            availableFrom: property['availableFrom'],
            propertySize: property['propertySize'],
            bathrooms: property['bathrooms'],
            agentDetails: property['agentDetails'],
            amenities: property['amenities'],
            developedBy: property['developedBy'],
            uniquePropertyId: property['uniquePropertyId'],
            agentName: property['agentName'], // Replace with actual agent name
            agentContact: property['agentContact'], // Replace with actual agent contact details
            agentImageUrl: property['agentImageUrl']
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> imgUrls = List<String>.from(property['imgUrls']);

    return InkWell(
      onTap: () => _showPropertyDetails(context),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 350.0,
                enableInfiniteScroll: true,
                autoPlay: true,
                viewportFraction: 1.0, // Set viewportFraction to 1.0 for edge-to-edge images
              ),
              items: imgUrls.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    );
                  },
                );
              }).toList(),
            ),

            ListTile(
              title: Text(
                '${property['price'].toString()} Riyals/year',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF013c7e),
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon(Icons.location_on, color: Color(0xFF013c7e)),
                      SizedBox(width: 2),
                      Text(property['propertyType']),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF013c7e)),
                      SizedBox(width: 4),
                      Text(property['location']),
                    ],
                  ),
                  SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(Icons.king_bed, color: Color(0xFF013c7e)),
                      SizedBox(width: 4),
                      Text(property['bedrooms']),
                      SizedBox(width: 16),
                      Icon(Icons.square_foot, color: Color(0xFF013c7e)),
                      SizedBox(width: 4),
                      Text(property['propertySize']),
                      SizedBox(width: 16),
                      Icon(Icons.bathtub, color: Color(0xFF013c7e)),
                      SizedBox(width: 4),
                      Text(property['bathrooms']),
                    ],
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}
