import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ckgoat/main.dart';
import 'package:ckgoat/pages/SellAnimal/FormPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding_resolver/geocoding_resolver.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:ckgoat/pages/BuyAnimals/AnimalPage.dart';

class FilterSection extends StatefulWidget {
  const FilterSection({Key? key}) : super(key: key);

  @override
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  List favorites = [];
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

  // Pagination-related variables
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> animalDocs = [];
  bool isFetchingMore = false;
  bool hasMore = true; // To check if there are more documents to load
  DocumentSnapshot?
      lastDocument; // Track the last document from the previous batch
  int documentLimit = 10; // Number of documents to fetch per request

  @override
  void initState() {
    super.initState();
    _fetchAnimals(); // Initial fetch
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingMore) {
        _fetchMoreAnimals(); // Fetch more animals when scrolled to the bottom
      }
    });
    fetchFav();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Initial data fetch
  Future<void> _fetchAnimals() async {
    Query query = FirebaseFirestore.instance
        .collection('animals')
        .limit(documentLimit); // Fetch only 'documentLimit' documents

    if (selectedCity != 'All India' && city != null) {
      query = query.where('city', isEqualTo: city);
    }

    if (selectedAnimalType != "All") {
      query = query.where('animalType', isEqualTo: selectedAnimalType);
    }

    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        animalDocs = querySnapshot.docs;
        lastDocument = querySnapshot.docs.last; // Save the last document
        hasMore = querySnapshot.docs.length ==
            documentLimit; // Check if there are more documents
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Show the bottom sheet to select an animal type
  void _showAnimalTypeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final AppLocalizations localizations = AppLocalizations.of(context)!;
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    localizations.translate('initial_select_animal_type'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                AnimalTypeButton('All', "None"),
                AnimalTypeButton("Cow", 'assets/cow.png'),
                AnimalTypeButton("Buffalo", 'assets/buffalo.png'),
                AnimalTypeButton("Sheep", 'assets/sheep.png'),
                AnimalTypeButton("Goat", 'assets/goat.png'),
                AnimalTypeButton("Horse", 'assets/horse.png'),
                AnimalTypeButton("Birds", 'assets/bird.png'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget AnimalTypeButton(animal, imagePath) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0,
          side: const BorderSide(color: Colors.deepOrange, width: 1.5),
        ),
        onPressed: () {
          setState(() {
            selectedAnimalType = animal;
            _fetchAnimals(); // Refresh data based on selection
          });
          Navigator.pop(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(localizations.translate(animal.toLowerCase()),
                style: const TextStyle(fontSize: 18, color: Colors.deepOrange)),
            (imagePath != "None")
                ? Image.asset(imagePath, height: 80)
                : Container(),
          ],
        ),
      ),
    );
  }

  // Fetch more data when scrolling to the bottom
  Future<void> _fetchMoreAnimals() async {
    if (!hasMore) {
      return;
    }

    Query query = FirebaseFirestore.instance
        .collection('animals')
        .limit(documentLimit)
        .startAfterDocument(
            lastDocument!); // Continue after last fetched document

    if (selectedCity != 'All India' && city != null) {
      query = query.where('city', isEqualTo: city);
    }

    if (selectedAnimalType != "All") {
      query = query.where('animalType', isEqualTo: selectedAnimalType);
    }

    setState(() {
      isFetchingMore = true;
    });

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        animalDocs.addAll(querySnapshot.docs); // Add new documents to the list
        lastDocument = querySnapshot.docs.last; // Save the new last document
        hasMore = querySnapshot.docs.length ==
            documentLimit; // Check if there are more documents
        isFetchingMore = false;
      });
    } else {
      setState(() {
        isFetchingMore = false;
      });
    }
  }

  // UI Code
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on),
                  SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!
                        .translate('flsec_select_location'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => showLocationDialog(context),
                child: Text(selectedCity),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Animal type selection button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.pets),
                  SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!
                        .translate('initial_select_animal_type'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                // width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showAnimalTypeSelection(context),
                  child: Text(
                    AppLocalizations.of(context)!
                        .translate(selectedAnimalType!.toLowerCase()),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisExtent: 230,
                            mainAxisSpacing: 15,
                            crossAxisCount: 2,
                            crossAxisSpacing: 15),
                    itemCount: animalDocs.length + (isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == animalDocs.length) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final doc = animalDocs[index];
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
                              builder: (context) =>
                                  AnimalPage(animalId: doc.id),
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
                                      height: 150,
                                      width: double.infinity,
                                      child: CachedNetworkImage(
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
                                  icon: Icon(
                                    isFavorite(doc.id)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite(doc.id)
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    toggleFavorite(doc.id);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
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

  Future<void> toggleFavorite(String animalId) async {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentSnapshot userDoc = await userDocRef.get();

    // Cast the document data to Map<String, dynamic>
    setState(() {
      favorites = (userDoc.data() as Map<String, dynamic>)['favorites'] ?? [];
    });

    if (favorites.contains(animalId)) {
      // Remove from favorites
      await userDocRef.update({
        'favorites': FieldValue.arrayRemove([animalId])
      });
      setState(() {
        favorites.remove(animalId);
      });
    } else {
      // Add to favorites
      await userDocRef.update({
        'favorites': FieldValue.arrayUnion([animalId])
      });
      setState(() {
        favorites.add(animalId);
      });
    }
  }

  Future<void> fetchFav() async {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentSnapshot userDoc = await userDocRef.get();

    // Cast the document data to Map<String, dynamic>
    setState(() {
      favorites = (userDoc.data() as Map<String, dynamic>)['favorites'] ?? [];
    });
  }

  bool isFavorite(
    String animalId,
  ) {
    return favorites.contains(animalId);
  }
}
