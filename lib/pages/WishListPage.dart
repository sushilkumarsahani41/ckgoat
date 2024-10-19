import 'package:ckgoat/pages/BuyAnimals/animalPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization.dart';
import '../widgets/animalCard.dart';

class Wishlistpage extends StatefulWidget {
  const Wishlistpage({super.key});

  @override
  State<Wishlistpage> createState() => _WishlistpageState();
}

class _WishlistpageState extends State<Wishlistpage> {
  List favorites = [];
  String? uid;
  List animals = [];
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchFav();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Wishlist",
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 230,
                    mainAxisSpacing: 15,
                    crossAxisCount: 2,
                    crossAxisSpacing: 15),
                itemCount: animals.length,
                itemBuilder: (context, index) {
                  final doc = animals[index];
                  return AnimalCard(
                    doc: doc,  // Pass the Firestore DocumentSnapshot
                    isFavorite: isFavorite(doc.id),  // Check if it's in the favorites
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnimalPage(animalId: doc.id),  // Pass doc.id to the next page
                        ),
                      );
                    },
                    toggleFavorite: () {
                      toggleFavorite(doc.id);  // Call your toggleFavorite function
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isFavorite(
    String animalId,
  ) {
    return favorites.contains(animalId);
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

  fetchFav() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      uid = pref.getString('uid');
    });
    var userData = await db.collection('users').doc(uid).get();
    if (userData.exists) {
      var fav = userData.data()!['favorites'];
      setState(() {
        favorites = fav;
      });
      for (String animal in fav) {
        var doc = await db.collection('animals').doc(animal).get();
        setState(() {
          animals.add(doc);
        });
      }
      print(animals);
    }
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
      lactation =
          '$lactationNum${_getNumberSuffix(lactationNum)} ${localization.translate('initial_lactation')}';
    }

    // Convert age from months to years and months
    int years = ageInMonths ~/ 12;
    int months = ageInMonths % 12;
    String age = '';
    if (years > 0) {
      age = '${years}y';
    }
    if (months > 0) {
      age += '${age.isNotEmpty ? ' and ' : ''}${months}m';
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
}
