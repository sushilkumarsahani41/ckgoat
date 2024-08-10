import 'package:ckgoat/pages/SellAnimal/TypePage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimalFormProvider with ChangeNotifier {
  String? animalType;
  String? breed;
  int? age; // Age in months
  double? weight; // Weight as double
  double? price;
  String? title;
  String? description;
  String? addressLine1;
  String? city;
  String? state;
  String? pinCode;
  String? mobileNumber;

  void setAnimalType(String type) {
    animalType = type;
    notifyListeners();
  }

  void setPrimaryInfo(String breed, int years, int months, double weight, double price) {
    this.breed = breed;
    this.age = (years * 12) + months; // Calculate age in months
    this.weight = weight;
    this.price = price;
    notifyListeners();
  }

  void setSecondaryInfo(String title, String description, String addressLine1, String city, String state, String pinCode, String mobileNumber) {
    this.title = title;
    this.description = description;
    this.addressLine1 = addressLine1;
    this.city = city;
    this.state = state;
    this.pinCode = pinCode;
    this.mobileNumber = mobileNumber;
    notifyListeners();
  }
}

class SellAnimalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sell Your Animal",
          style: GoogleFonts.archivoBlack(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange),
        ),
      ),
      body: AnimalTypePage(),
    );
  }
}
