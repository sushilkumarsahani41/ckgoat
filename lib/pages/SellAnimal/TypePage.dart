import 'package:ckgoat/pages/SellAnimal/FormPage.dart';
import 'package:ckgoat/pages/SellAnimal/PrimaryInfoPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimalTypePage extends StatelessWidget {
  const AnimalTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimalTypeButton(animal: "Cow", imagePath: 'assets/cow.png'),
              AnimalTypeButton(
                  animal: "Buffalo", imagePath: 'assets/buffalo.png'),
              AnimalTypeButton(animal: "Sheep", imagePath: 'assets/sheep.png'),
              AnimalTypeButton(animal: "Goat", imagePath: 'assets/goat.png'),
              AnimalTypeButton(animal: "Horse", imagePath: 'assets/horse.png'),
              AnimalTypeButton(animal: "Birds", imagePath: 'assets/bird.png'),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimalTypeButton extends StatelessWidget {
  final String animal;
  final String imagePath;

  const AnimalTypeButton({super.key, required this.animal, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ), // Background color
          elevation: 0, // Remove button shadow
          side:
              const BorderSide(color: Colors.deepOrange, width: 1.5), // Border color
        ),
        onPressed: () {
          Provider.of<AnimalFormProvider>(context, listen: false)
              .setAnimalType(animal);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrimaryInfoPage()),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(animal,
                style: const TextStyle(fontSize: 18, color: Colors.deepOrange)),
            Image.asset(
              imagePath,
              height: 80,
              // opacity: Animation(), // Adjust the size as needed
            ),
          ],
        ),
      ),
    );
  }
}
