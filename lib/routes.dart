import 'package:ckgoat/pages/Login.dart';
import 'package:ckgoat/pages/SellAnimal/FormPage.dart';
import 'package:ckgoat/pages/home.dart';
import 'package:ckgoat/pages/signup.dart';
import 'package:ckgoat/pages/splashScreen.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return _createRoute(const Splashscreen());
      case '/home':
        return _createRoute(const HomeScreen());
      case '/login':
        return _createRoute(const LoginScreen());
      case '/signup':
        return _createRoute(const SignupPage());
      case '/sellAnimal':
        return _createRoute(const SellAnimalPage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR: Route not found!'),
        ),
      );
    });
  }
}
