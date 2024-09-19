import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart'; // Importing MyApp for locale change handling

class LanguageSelectionPage extends StatelessWidget {
  final Function(Locale) onLocaleChange;

  const LanguageSelectionPage({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('select_language'),
          style: GoogleFonts.archivoBlack(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLanguageCard(
              context,
              language: AppLocalizations.of(context)!.translate('english'),
              subtitle: 'English',
              locale: const Locale('en'),
              onLocaleChange: onLocaleChange,
            ),
            const SizedBox(height: 16),
            _buildLanguageCard(
              context,
              language: AppLocalizations.of(context)!.translate('hindi'),
              subtitle: 'हिन्दी',
              locale: const Locale('hi'),
              onLocaleChange: onLocaleChange,
            ),
            const SizedBox(height: 16),
            _buildLanguageCard(
              context,
              language: AppLocalizations.of(context)!.translate('marathi'),
              subtitle: 'मराठी',
              locale: const Locale('mr'),
              onLocaleChange: onLocaleChange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context, {
    required String language,
    required String subtitle,
    required Locale locale,
    required Function(Locale) onLocaleChange,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          onLocaleChange(locale);
          Navigator.pop(context); // Close the page after selection
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.language, color: Colors.deepOrange, size: 40),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: GoogleFonts.ptSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: GoogleFonts.ptSans(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
