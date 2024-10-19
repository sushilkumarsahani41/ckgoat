import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../localization.dart';

class AnimalCard extends StatelessWidget {
  final DocumentSnapshot doc;  // Accept Firestore DocumentSnapshot
  final bool isFavorite;
  final VoidCallback onTap;
  final Function toggleFavorite;

  const AnimalCard({
    super.key,
    required this.doc,  // DocumentSnapshot is passed here
    required this.isFavorite,
    required this.onTap,
    required this.toggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    // Extract data from the document
    final data = doc.data() as Map<String, dynamic>;
    final thumbnail = data['thumbnail'] as String?;

    return GestureDetector(
      onTap: onTap,
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
                    child: thumbnail != null && thumbnail.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: thumbnail,
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
                    )
                        : const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
              decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                  shape: BoxShape.circle,
                  color: Colors.white),
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  toggleFavorite();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to generate the title (you can pass this from parent)
  String generateTitle(BuildContext context, Map<String, dynamic> data) {
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
      lactation = '$lactationNum${_getNumberSuffix(lactationNum)} ${localization.translate('initial_lactation')}';
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
    return 'No title available'; // Example return value, replace it with actual logic
  }

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
