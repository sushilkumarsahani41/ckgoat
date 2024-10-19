// Adjust the path as necessary
import 'package:flutter/material.dart';

import '../localization.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('pry_privacyHeading')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.translate('pry_welcomeMessage'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(localizations.translate('pry_welcomeIntro')),
              const SizedBox(height: 10),
              Text(localizations.translate('pry_privacyGoal')),
              const SizedBox(height: 20),
              Text(
                localizations.translate('pry_introduction'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations.translate('pry_introductionDetail')),
              const SizedBox(height: 20),
              Text(
                localizations.translate('pry_infoWeCollect'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations.translate('pry_personalInfo')),
              const SizedBox(height: 5),
              Text(localizations.translate('pry_nonPersonalInfo')),
              const SizedBox(height: 20),
              Text(
                localizations.translate('pry_howWeUse'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations.translate('pry_usageDetails')),
              const SizedBox(height: 20),
              Text(
                localizations.translate('pry_sharingInfo'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations.translate('pry_sharingDetails')),
              const SizedBox(height: 20),
              Text(
                localizations.translate('pry_dataSecurity'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations.translate('pry_securityDetails')),
              const SizedBox(height: 20),
              Text(
                localizations.translate('pry_userResponsibilities'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations.translate('pry_responsibilityDetails')),
              const SizedBox(height: 20),
              Text(
                localizations.translate('pry_cookies'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations.translate('pry_cookiesDetails')),
              const SizedBox(height: 20),
              Text(
                localizations.translate('pry_userRights'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations.translate('pry_rightsDetails')),
              const SizedBox(height: 20),
              Text(
                localizations.translate('pry_policyChanges'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations.translate('pry_changesDetails')),
              const SizedBox(height: 20),
              Text(
                localizations.translate('pry_contactInfo'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations.translate('pry_contactDetails')),
            ],
          ),
        ),
      ),
    );
  }
}
