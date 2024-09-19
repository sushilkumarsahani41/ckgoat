import 'package:ckgoat/main.dart';
import 'package:flutter/material.dart'; // Adjust the path as necessary

class TermsAndConditionsPage extends StatelessWidget {
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(localizations
                  .translate('welcomeIntro')), // Use translate method
              SizedBox(height: 10),
              Text(localizations.translate('agenda')), // Use translate method
              SizedBox(height: 10),
              Text(localizations
                  .translate('termsInstruction')), // Use translate method
              SizedBox(height: 20),
              Text(
                localizations
                    .translate('userAgreement'), // Use translate method
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations
                  .translate('userAgreementDetail')), // Use translate method
              SizedBox(height: 20),
              Text(
                localizations
                    .translate('platformPurpose'), // Use translate method
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations
                  .translate('platformPurposeDetail')), // Use translate method
              SizedBox(height: 20),
              Text(
                localizations
                    .translate('animalBehavior'), // Use translate method
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations
                  .translate('animalBehaviorDetail')), // Use translate method
              SizedBox(height: 20),
              Text(
                localizations
                    .translate('postTransaction'), // Use translate method
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations
                  .translate('postTransactionDetail')), // Use translate method
              SizedBox(height: 20),
              Text(
                localizations.translate('governingLaw'), // Use translate method
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations
                  .translate('governingLawDetail')), // Use translate method
            ],
          ),
        ),
      ),
    );
  }
}
