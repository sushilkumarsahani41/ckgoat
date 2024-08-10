import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimalPage extends StatefulWidget {
  final String animalId;

  AnimalPage({required this.animalId});

  @override
  _AnimalPageState createState() => _AnimalPageState();
}

class _AnimalPageState extends State<AnimalPage> {
  int _current = 0;
  Map<String, dynamic>? animalData;
  List<String> images = [];

  @override
  void initState() {
    super.initState();
    _fetchAnimalData();
  }

  void _fetchAnimalData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('animals')
          .doc(widget.animalId)
          .get();

      if (snapshot.exists) {
        setState(() {
          animalData = snapshot.data() as Map<String, dynamic>?;
          images = List<String>.from(animalData?['uploadedUrls'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching animal data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Page'),
        backgroundColor: Colors.deepOrange,
      ),
      body: animalData == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CarouselSlider(
                            items: images
                                .map((i) => ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child:
                                          Image.network(i, fit: BoxFit.cover),
                                    ))
                                .toList(),
                            options: CarouselOptions(
                              height: 400,
                              autoPlay: false,
                              enlargeCenterPage: true,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _current = index;
                                });
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: images.asMap().entries.map((entry) {
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    _current = entry.key;
                                  }),
                                  child: Container(
                                    width: 8.0,
                                    height: 8.0,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _current == entry.key
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  animalData?['title'] ?? 'No title',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.grey),
                                    SizedBox(width: 5),
                                    Text(
                                        '${animalData?['addressLine1']}, ${animalData?['city']}',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Colors.grey),
                                    SizedBox(width: 5),
                                    Text('Age: ${animalData?['age']}',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.phone, color: Colors.grey),
                                    SizedBox(width: 5),
                                    Text('${animalData?['mobileNumber']}',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.pets, color: Colors.grey),
                                    SizedBox(width: 5),
                                    Text('Breed Info: ${animalData?['breed']}',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.scale, color: Colors.grey),
                                    SizedBox(width: 5),
                                    Text('Weight: ${animalData?['weight']} kg',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.attach_money,
                                        color: Colors.grey),
                                    SizedBox(width: 5),
                                    Text('Price: \$${animalData?['price']}',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Description:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  animalData?['description'] ??
                                      'No description',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _handleCallNow();
                          },
                          icon: Icon(Icons.phone),
                          label: Text('Call Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            _handleWhatsApp();
                          },
                          icon: Icon(Icons.message),
                          label: Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  void _handleCallNow() {
    // Implement call logic here
    print('Calling Now...');
    _makePhoneCall('+91${animalData?['mobileNumber']}');
  }

  launchWhatsappWithMobileNumber(mobileNumber, message) async {
    final url = "https://api.whatsapp.com/send?phone=$mobileNumber";
    print(url);
    if (await canLaunchUrl(Uri.parse(Uri.encodeFull(url)))) {
      await launchUrl(Uri.parse(Uri.encodeFull(url)));
    } else {
      throw 'Could not launch $url';
    }
  }

  void _handleWhatsApp() {
    // Implement WhatsApp message logic here
    print('Sending WhatsApp Message...');
    launchWhatsappWithMobileNumber('91${animalData?['mobileNumber']}', "Hello");
  }
}
