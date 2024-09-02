import 'package:ckgoat/pages/BuyAnimals/FilterSection.dart';
import 'package:flutter/material.dart';

class BuyHome extends StatefulWidget {
  const BuyHome({super.key});

  @override
  State<BuyHome> createState() => _BuyHomeState();
}

class _BuyHomeState extends State<BuyHome> {
  bool isSellHide = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          isSellHide
              ? ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/sellAnimal');
                  },
                  child: const Text('Sell Your Animal'),
                )
              : SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 30,
                        child: Container(
                          height: 170,
                          width: MediaQuery.of(context).size.width - 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: const Color.fromARGB(255, 55, 160, 247),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width:
                                          120, // Adjusted width for better layout
                                      padding: const EdgeInsets.only(left: 10),
                                      child: const Text(
                                        "No More Selling From Bazaar",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/sellAnimal');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        backgroundColor:
                                            Colors.white, // Background color
                                      ),
                                      child: const Text(
                                        "Sell Now",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(), // This will push the image to the right
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/happDog.png',
                            height: 200,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 20,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isSellHide = !isSellHide;
                            });
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
          const Expanded(child: FilterSection())
        ],
      ),
    );
  }
}
