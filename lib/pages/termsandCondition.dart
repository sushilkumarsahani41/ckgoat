import 'package:flutter/material.dart';

import '../localization.dart'; // Adjust the path as necessary

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            localizations.translate('termsHeading')), // Use translate method
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations
                    .translate('welcomeMessage'), // Use translate method
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(localizations
                  .translate('welcomeIntro')), // Use translate method
              const SizedBox(height: 10),
              Text(localizations.translate('agenda')), // Use translate method
              const SizedBox(height: 10),
              Text(localizations
                  .translate('termsInstruction')), // Use translate method
              const SizedBox(height: 20),
              Text(
                localizations
                    .translate('userAgreement'), // Use translate method
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations
                  .translate('userAgreementDetail')), // Use translate method
              const SizedBox(height: 20),
              Text(
                localizations
                    .translate('platformPurpose'), // Use translate method
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations
                  .translate('platformPurposeDetail')), // Use translate method
              const SizedBox(height: 20),
              Text(
                localizations
                    .translate('animalBehavior'), // Use translate method
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations
                  .translate('animalBehaviorDetail')), // Use translate method
              const SizedBox(height: 20),
              Text(
                localizations
                    .translate('postTransaction'), // Use translate method
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations
                  .translate('postTransactionDetail')), // Use translate method
              const SizedBox(height: 20),
              Text(
                localizations.translate('governingLaw'), // Use translate method
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(localizations
                  .translate('governingLawDetail')), // Use translate method
            ],
          ),
        ),
      ),
    );
  }
}
