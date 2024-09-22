import 'package:ckgoat/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LanguageSelectionPage.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLanguageSelection();
  }

  // Simulates a load or delay of 3 seconds and then navigates to the language selection page
  void _navigateToLanguageSelection() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) {
      return; // Check if the widget is still mounted before using context
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? uid = pref.getString('uid') ?? '';
    if (uid.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LanguageSelectionPage(
            onLocaleChange: (locale) {
              _changeLocale(locale); // Callback to change locale
            },
          ),
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
    // If uid is empty, navigate to language selection page
  }

  // Changes the locale and saves it
  void _changeLocale(Locale locale) async {
    setState(() {
      MyApp.of(context)?.setLocale(locale); // Use MyApp's locale setter
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('languageCode', locale.languageCode);

    if (!mounted) {
      return; // Check if the widget is still mounted before using context
    }

    // After selecting language, navigate to the home page
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/GOAT.png',
              width: 300,
            ),
            Text(
              'CK Farm',
              style: GoogleFonts.ptSerif(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.deepOrange,
            ),
          ],
        ),
      ),
    );
  }
}
