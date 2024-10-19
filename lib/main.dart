import 'package:ckgoat/firebase_options.dart';
import 'package:ckgoat/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';

import 'localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // Default to English
  static const String localeKey = 'selected_locale'; // Key for storing locale

  @override
  void initState() {
    super.initState();
    _loadLocale();
    checkForUpdate(); // Check for updates when the app starts
  }

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocale = prefs.getString(localeKey);
    if (savedLocale != null) {
      setState(() {
        _locale = Locale(savedLocale);
      });
    }
  }

  Future<void> _saveLocale(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(localeKey, locale.languageCode);
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    _saveLocale(locale); // Save the selected locale
  }

  Future<void> checkForUpdate() async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Immediate update (forces user to update immediately)
          InAppUpdate.performImmediateUpdate().catchError((e) {
            print('Immediate update failed: $e');
          });
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Start flexible update (allow user to download and update in background)
          InAppUpdate.startFlexibleUpdate().catchError((e) {
            print('Flexible update failed: $e');
          }).then((result) {
            if (result == AppUpdateResult.success) {
              // Show dialog to ask user to restart after update is downloaded
              showFlexibleUpdateDialog();
            }
          });
        }
      }
    } catch (e) {
      print('Failed to check for updates: $e');
    }
  }

  void showFlexibleUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Ready'),
        content:const Text('An update has been downloaded. Please restart the app.'),
        actions: [
          TextButton(
            onPressed: () {
              InAppUpdate.completeFlexibleUpdate().catchError((e) {
                print('Failed to complete flexible update: $e');
              });
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CK Farm',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate, // Custom localization delegate
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
        Locale('mr', ''), // Marathi
      ],
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
