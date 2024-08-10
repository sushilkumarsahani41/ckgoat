import 'package:ckgoat/pages/BuyAnimals/AnimalPage.dart';
import 'package:ckgoat/pages/BuyAnimals/BuyAnimalHome.dart';
import 'package:ckgoat/pages/profilepage.dart';
import 'package:ckgoat/pages/shop.dart';
import 'package:ckgoat/pages/forum/community.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Total number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CK GOAT FARM",
                  style: GoogleFonts.archivoBlack(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BuyHome(),
            ShopPage(),
            ForumPage(),
            UserProfilePage(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  right: BorderSide(color: Colors.grey),
                  left: BorderSide(color: Colors.grey),
                  top: BorderSide(color: Colors.grey),
                  bottom: BorderSide.none),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  spreadRadius: 2,
                  blurRadius: 5,
                  // offset: const Offset(3, 4),
                  color: Colors.grey.shade400,
                ),
              ]),
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.deepOrange,
            // indicator: BoxDecoration(
            //   color: Colors.deepOrange, // Indicator color
            //   shape: BoxShape.circle, // Circular shape around the icon
            // ),
            labelColor: Colors.deepOrange, // Color of text when selected
            unselectedLabelColor:
                Colors.black87, // Color of text when not selected
            tabs: [
              Tab(icon: Icon(Icons.pets), text: 'Pets'),
              Tab(icon: Icon(Icons.storefront_outlined), text: 'Shop'),
              Tab(icon: Icon(Icons.diversity_3_outlined), text: 'Family'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
