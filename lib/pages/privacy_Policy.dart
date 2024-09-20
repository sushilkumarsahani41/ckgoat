import 'package:ckgoat/main.dart'; // Adjust the path as necessary
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(localizations.translate('pry_welcomeIntro')),
              SizedBox(height: 10),
              Text(localizations.translate('pry_privacyGoal')),
              SizedBox(height: 20),
              Text(
                localizations.translate('pry_introduction'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations.translate('pry_introductionDetail')),
              SizedBox(height: 20),
              Text(
                localizations.translate('pry_infoWeCollect'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations.translate('pry_personalInfo')),
              SizedBox(height: 5),
              Text(localizations.translate('pry_nonPersonalInfo')),
              SizedBox(height: 20),
              Text(
                localizations.translate('pry_howWeUse'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations.translate('pry_usageDetails')),
              SizedBox(height: 20),
              Text(
                localizations.translate('pry_sharingInfo'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations.translate('pry_sharingDetails')),
              SizedBox(height: 20),
              Text(
                localizations.translate('pry_dataSecurity'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations.translate('pry_securityDetails')),
              SizedBox(height: 20),
              Text(
                localizations.translate('pry_userResponsibilities'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations.translate('pry_responsibilityDetails')),
              SizedBox(height: 20),
              Text(
                localizations.translate('pry_cookies'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations.translate('pry_cookiesDetails')),
              SizedBox(height: 20),
              Text(
                localizations.translate('pry_userRights'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations.translate('pry_rightsDetails')),
              SizedBox(height: 20),
              Text(
                localizations.translate('pry_policyChanges'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations.translate('pry_changesDetails')),
              SizedBox(height: 20),
              Text(
                localizations.translate('pry_contactInfo'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(localizations.translate('pry_contactDetails')),
            ],
          ),
        ),
      ),
    );
  }
}
