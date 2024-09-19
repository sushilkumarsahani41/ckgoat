import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ckgoat/main.dart';
import 'package:flutter/material.dart';
import 'package:geocoding_resolver/geocoding_resolver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ckgoat/pages/BuyAnimals/AnimalPage.dart';

class FilterSection extends StatefulWidget {
  const FilterSection({Key? key}) : super(key: key);

  @override
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  String selectedCity = 'All India';
  String? selectedAnimalType = 'All';
  String? city;
  String? state;
  bool isLoading = false;
  bool locationLoading = false; // To track location fetching state

  final List<String> animalTypes = [
    'All',
    'Cow',
    'Buffalo',
    'Sheep',
    'Goat',
    'Horse',
    'Birds'
  ];
  final TextEditingController pincodeController = TextEditingController();

  void showLocationDialog(BuildContext context) {
    TextEditingController pincodeController = TextEditingController();
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.location_city, color: Colors.deepOrange),
              SizedBox(width: 10),
              Text(
                  AppLocalizations.of(context)!
                      .translate('flsec_select_location'),
                  style: TextStyle(color: Colors.deepOrange)),
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      maxLength: 6,
                      controller: pincodeController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .translate('flsec_enter_pincode'),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search, color: Colors.deepOrange),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _fetchLocationData(
                                  pincodeController.text, setStateDialog);
                            }
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty || value.length != 6) {
                          return AppLocalizations.of(context)!
                              .translate('flsec_invalid_pincode');
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    if (isLoading)
                      CircularProgressIndicator(color: Colors.deepOrange),
                    if (city != null && state != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('$city, $state',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.deepOrange,
                                decoration: TextDecoration.underline)),
                      ),
                    SizedBox(height: 10),
                    if (locationLoading)
                      CircularProgressIndicator(color: Colors.deepOrange),
                    if (!locationLoading)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        icon: Icon(Icons.my_location, color: Colors.white),
                        label: Text(
                            AppLocalizations.of(context)!
                                .translate('flsec_use_current_location'),
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          setStateDialog(() {
                            locationLoading = true;
                          });
                          _getCurrentLocation(setStateDialog);
                        },
                      ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text(
                  AppLocalizations.of(context)!.translate('flsec_cancel'),
                  style: TextStyle(color: Colors.deepOrange)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String generateTitle(context, Map<String, dynamic> data) {
    // Retrieve necessary fields
    final localization = AppLocalizations.of(context)!;
    String animalType = data['animalType'] ?? '';
    String gender = data['gender'] ?? '';
    String breed = data['breed'] ?? '';
    String weight = data['weight'] != null ? '${data['weight']}kg' : '';
    int ageInMonths = data['age'] ?? 0;
    String price = data['price'] != null
        ? '${localization.translate('common_at_only')} ₹${data['price']}'
        : '';
    int lactationNum = data['lactation'] ?? 0;
    String milkCapacity =
        data['milkCapacity'] != null ? '${data['milkCapacity']}L' : '';

    // Convert lactation number to "1st", "2nd", "3rd", etc.
    String lactation = '';
    if (lactationNum > 0) {
      lactation = '$lactationNum' +
          _getNumberSuffix(lactationNum) +
          ' ${localization.translate('initial_lactation')}';
    }

    // Convert age from months to years and months
    int years = ageInMonths ~/ 12;
    int months = ageInMonths % 12;
    String age = '';
    if (years > 0) {
      age = '${years}y';
    }
    if (months > 0) {
      age += (age.isNotEmpty ? ' and ' : '') + '${months}m';
    }
    if (age.isEmpty) {
      age = 'less than a month';
    }

    // Generate the title based on gender and breed
    if (breed.isNotEmpty) {
      if (gender == 'Male') {
        return '${localization.translate(breed)} ${localization.translate(animalType.toLowerCase())} | $weight | ${localization.translate('initial_age')} $age | $price';
      } else if (gender == 'Female') {
        return '${localization.translate(breed)} ${localization.translate(animalType.toLowerCase())} | $lactation - $milkCapacity ${localization.translate('milk')} | $weight | ${localization.translate('initial_age')} $age | $price';
      }
    } else {
      return '${localization.translate(animalType.toLowerCase())} | $weight | ${localization.translate('initial_age')} $age | $price';
    }

    // Return a default title if no sufficient data
    return 'No title available';
  }

// Helper function to get the correct suffix for the lactation number
  String _getNumberSuffix(int number) {
    if (number >= 11 && number <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<void> _fetchLocationData(
      String pincode, void Function(void Function()) setStateDialog) async {
    final url = Uri.parse(
        'https://api.ckgoat.greatshark.tech/location/pincode/$pincode');
    setStateDialog(() => isLoading = true);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['district'] != null) {
          setStateDialog(() {
            city = data['district'];
            state = data['state'];
            setState(() {
              selectedCity = "$city, $state";
            }); // Automatically set the city
            isLoading = false;
            Navigator.of(context).pop(); // Close dialog after setting city
          });
        } else {
          throw Exception('Invalid response data');
        }
      } else {
        throw Exception('Invalid Pincode');
      }
    } catch (error) {
      setStateDialog(() {
        isLoading = false;
      });
      pincodeController.text = "";
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid Pincode. Please try again.')));
    }
  }

  Future<void> _getCurrentLocation(
      void Function(void Function()) setStateDialog) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location services are disabled.')));
      setStateDialog(() => locationLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permissions are denied')));
        setStateDialog(() => locationLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      setStateDialog(() => locationLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    try {
      GeoCoder geoCoder = GeoCoder();
      Address address = await geoCoder.getAddressFromLatLng(
          latitude: position.latitude.toDouble(),
          longitude: position.longitude.toDouble());

      final pincode = address.addressDetails.postcode;

      if (pincode != null && pincode.isNotEmpty) {
        _fetchLocationData(pincode, setStateDialog);
        setStateDialog(() {
          locationLoading = false;
        });
      } else {
        throw Exception('Failed to fetch postcode from location.');
      }
    } catch (error) {
      setStateDialog(() {
        locationLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Failed to fetch city from location. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('animals');

    if (selectedCity != 'All India') {
      query = query.where('city', isEqualTo: city);
    }

    if (selectedAnimalType != "All") {
      query = query.where('animalType', isEqualTo: selectedAnimalType);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.location_on),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => showLocationDialog(context),
                child: Text(selectedCity),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: animalTypes.map((String type) {
                bool isSelected = selectedAnimalType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          isSelected ? Colors.deepOrange : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedAnimalType = type;
                      });
                    },
                    child: Text(AppLocalizations.of(context)!
                        .translate(type.toLowerCase())),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text(AppLocalizations.of(context)!
                          .translate('flsec_error')));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(AppLocalizations.of(context)!
                          .translate('flsec_no_animals_found')));
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisExtent: 230,
                      mainAxisSpacing: 15,
                      crossAxisCount: 2,
                      crossAxisSpacing: 15),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final imageUrls =
                        data['uploadedUrls'] as List<dynamic>? ?? [];
                    final firstImageUrl =
                        imageUrls.isNotEmpty ? imageUrls[0] as String : null;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnimalPage(animalId: doc.id),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                  child: SizedBox(
                                    height:
                                        150, // Fixed height to prevent layout shifting
                                    width: double
                                        .infinity, // Full width for the image container
                                    child: Stack(
                                      alignment:
                                          Alignment.center, // Center the loader
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: firstImageUrl!,
                                          fit: BoxFit.cover,
                                          height: 150,
                                          width: double.infinity,
                                          placeholder: (context, url) =>
                                              const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        maxLines: 3,
                                        generateTitle(context, data),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 70,
                            child: Container(
                              width: 40,
                              decoration: const BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ], shape: BoxShape.circle, color: Colors.white),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.favorite_outline,
                                  color: Colors.black45,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
