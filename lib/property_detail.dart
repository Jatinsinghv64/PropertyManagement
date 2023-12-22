import 'package:flutter/material.dart';
import 'mapBox.dart';

class PropertyDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final String propertyType;
  final String bedrooms;
  final String availableFrom;
  final String propertySize;
  final String bathroom;
  final String agentDetails;
  final String facilities;
  final String developedBy;
  final String amenities;
  final String uniquePropertyId;

  PropertyDetailsPage({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.propertyType,
    required this.bedrooms,
    required this.availableFrom,
    required this.propertySize,
    required this.bathroom,
    required this.agentDetails,
    required this.facilities,
    required this.developedBy,
    required this.amenities,
    required this.uniquePropertyId,
  });

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
            Image.network(
              imageUrl,
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Center(
                  child: Text('Image failed to load'),
                );
              },
            ),


            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MapBoxScreen()));
                    },

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
                  ),SizedBox(height: 16),

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
                        buildRow(propertyType, 'Property Type', 22),
                        buildRow(bedrooms, 'Bedrooms', 22),
                        buildRow(availableFrom, 'Available From', 22),
                        buildRow(propertySize, 'Property Size', 22),
                        buildRow(bathroom, 'Bathroom', 22),
                        buildRow(agentDetails, 'Agent Details', 22),
                        buildRow(facilities, 'Facilities', 22),
                        buildRow(developedBy, 'Developed By', 22),
                        // Add more rows as needed
                      ],
                    ),
                  ),
                  SizedBox(height: 16,),
                  Container(
                    padding: EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
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
                              //fontWeight: FontWeight.bold,
                              color: Color(0xFF013c7e),
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )

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
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold,),
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
