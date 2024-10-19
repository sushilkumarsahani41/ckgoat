import 'package:ckgoat/main.dart';
import 'package:ckgoat/pages/BuyAnimals/buyAnimalHome.dart';
import 'package:ckgoat/pages/LanguageSelectionPage.dart';
import 'package:ckgoat/pages/SellAnimal/FormPage.dart';
import 'package:ckgoat/pages/WishListPage.dart';
import 'package:ckgoat/pages/profilepage.dart';
import 'package:ckgoat/pages/forum/community.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../localization.dart';

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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                width: 40,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ]),
                child: IconButton(
                  iconSize: 20,
                  // splashRadius: 6,
                  icon: const Icon(
                    Icons.translate,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    // Navigate to the WishListPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LanguageSelectionPage(
                          onLocaleChange: (locale) {
                            _setLocale(locale); // Callback to change locale
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                width: 40,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ]),
                child: IconButton(
                  icon: const Icon(Icons.favorite_outline,
                      color: Colors.deepOrange),
                  onPressed: () {
                    // Navigate to the WishListPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const Wishlistpage(), // Assuming WishListPage is imported
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
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

  void _setLocale(Locale locale) {
    setState(() {
      MyApp.of(context)?.setLocale(locale); // Use MyApp's locale setter
    });
  }
}
