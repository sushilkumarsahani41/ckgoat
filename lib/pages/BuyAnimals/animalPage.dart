
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ckgoat/main.dart';

class AnimalPage extends StatefulWidget {
  final String animalId;

  const AnimalPage({super.key, required this.animalId});

  @override
  // ignore: library_private_types_in_public_api
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
      if (kDebugMode) {
        print('Error fetching animal data: $e');
      }
    }
  }

  // Function to convert age in months to years and months
  String formatAge(int ageInMonths) {
    int years = ageInMonths ~/ 12;
    int months = ageInMonths % 12;
    String formattedAge = '';

    if (years > 0) {
      formattedAge = '$years years';
    }

    if (months > 0) {
      if (formattedAge.isNotEmpty) {
        formattedAge += ' and ';
      }
      formattedAge += '$months months';
    }

    if (formattedAge.isEmpty) {
      formattedAge = 'less than a month';
    }

    return formattedAge;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('animal_title')),
        backgroundColor: Colors.deepOrange,
      ),
      body: animalData == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CarouselSlider(
                            items: images
                                .map((i) => ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        i,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child; // Image is fully loaded, return the image
                                          } else {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.deepOrange,
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        (loadingProgress
                                                                .expectedTotalBytes ??
                                                            1)
                                                    : null,
                                              ),
                                            ); // Show CircularProgressIndicator while image is loading
                                          }
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                              child: Icon(Icons
                                                  .error)); // Handle image loading error
                                        },
                                      ),
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
                                    margin: const EdgeInsets.symmetric(
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (animalData?['title'] != null)
                                  Text(
                                    animalData?['title'] ??
                                        localizations
                                            .translate('animal_no_title'),
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['animalType'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.pets,
                                          color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_animal_type')}: ${localizations.translate(animalData!['animalType'].toLowerCase())}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['breed'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.pets,
                                          color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_breed')}: ${localizations.translate(animalData?['breed'])}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['gender'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.wc, color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_gender')}: ${localizations.translate(animalData!['gender'].toLowerCase())}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['age'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_age')}: ${formatAge(animalData?['age'])}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['lactation'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.replay,
                                          color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_lactation')}: ${animalData?['lactation']}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['milkCapacity'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.local_drink,
                                          color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_milk_capacity')}: ${animalData?['milkCapacity']}L',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['weight'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.scale,
                                          color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_weight')}: ${animalData?['weight']} kg',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['price'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_money,
                                          color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_price')}: ₹${animalData?['price']}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['address'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_address')}: ${animalData?['address']}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['city'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.location_city,
                                          color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_city')}: ${animalData?['city']}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['state'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.map, color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_state')}: ${animalData?['state']}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['pinCode'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.local_post_office,
                                          color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_pincode')}: ${animalData?['pinCode']}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 10),
                                if (animalData?['mobileNumber'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.phone,
                                          color: Colors.grey),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${localizations.translate('animal_mobile')}: ${animalData?['mobileNumber']}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
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
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
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
                          icon: const Icon(Icons.phone),
                          label:
                              Text(localizations.translate('animal_call_now')),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            _handleWhatsApp();
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
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
    _makePhoneCall('+91${animalData?['mobileNumber']}');
  }

  launchWhatsappWithMobileNumber(String mobileNumber, String message) async {
    final whatsappAppUrl =
        "whatsapp://send?phone=$mobileNumber&text=${Uri.encodeComponent(message)}";
    final whatsappWebUrl =
        "https://api.whatsapp.com/send?phone=$mobileNumber&text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(whatsappAppUrl))) {
      if (kDebugMode) {
        print('Launching WhatsApp App URL: $whatsappAppUrl');
      }
      await launchUrl(
        Uri.parse(whatsappAppUrl),
        mode: LaunchMode.externalApplication,
      );
    } else if (await canLaunchUrl(Uri.parse(whatsappWebUrl))) {
      if (kDebugMode) {
        print('Launching WhatsApp Web URL: $whatsappWebUrl');
      }
      await launchUrl(
        Uri.parse(whatsappWebUrl),
        mode: LaunchMode.externalNonBrowserApplication,
      );
    } else {
      if (kDebugMode) {
        print('Could not launch WhatsApp');
      }
    }
  }

  void _handleWhatsApp() async {
    launchWhatsappWithMobileNumber('91${animalData?['mobileNumber']}', "Hello");
  }
}
