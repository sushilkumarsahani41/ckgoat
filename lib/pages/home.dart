import 'package:ckgoat/main.dart';
import 'package:ckgoat/pages/BuyAnimals/BuyAnimalHome.dart';
import 'package:ckgoat/pages/SellAnimal/FormPage.dart';
import 'package:ckgoat/pages/profilepage.dart';
import 'package:ckgoat/pages/forum/community.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              Text(
                AppLocalizations.of(context)!
                    .translate('app_title'), // Corrected
                style: GoogleFonts.archivoBlack(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BuyHome(),
            SellAnimalPage(),
            ForumPage(),
            UserProfilePage(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              right: BorderSide(color: Colors.grey),
              left: BorderSide(color: Colors.grey),
              top: BorderSide(color: Colors.grey),
              bottom: BorderSide.none,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                spreadRadius: 2,
                blurRadius: 5,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.deepOrange,
            labelColor: Colors.deepOrange,
            unselectedLabelColor: Colors.black87,
            tabs: [
              Tab(
                icon: const Icon(Icons.pets),
                text:
                    AppLocalizations.of(context)!.translate('buy'), // Corrected
              ),
              Tab(
                icon: const Icon(Icons.pets),
                text: AppLocalizations.of(context)!
                    .translate('sell'), // Corrected
              ),
              Tab(
                icon: const Icon(Icons.diversity_3_outlined),
                text: AppLocalizations.of(context)!
                    .translate('family'), // Corrected
              ),
              Tab(
                icon: const Icon(Icons.person),
                text: AppLocalizations.of(context)!
                    .translate('profile'), // Corrected
              ),
            ],
          ),
        ),
      ),
    );
  }
}
