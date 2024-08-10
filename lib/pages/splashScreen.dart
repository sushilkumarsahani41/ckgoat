import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Simulates a load or delay of 3 seconds and then navigates to another screen
  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? uid = pref.getString('uid') ?? '';
    if (uid.isEmpty) {
      Navigator.popAndPushNamed(context, '/login');
    } else {
      Navigator.popAndPushNamed(context, '/home');
    }
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
              'CK Goat Farm',
              style: GoogleFonts.ptSerif(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange),
            ),
            const SizedBox(
              height: 20,
            ),
            const CircularProgressIndicator(
              color: Colors.deepOrange,
            )
          ],
        ),
      ),
    );
  }
}
