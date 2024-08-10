import 'package:ckgoat/pages/SellAnimal/FormPage.dart';
import 'package:ckgoat/pages/uploadPages.dart';
import 'package:ckgoat/services/UploadService.dart';
import 'package:ckgoat/widgets/snakbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class SecondaryInfoPage extends StatefulWidget {
  @override
  _SecondaryInfoPageState createState() => _SecondaryInfoPageState();
}

class _SecondaryInfoPageState extends State<SecondaryInfoPage> {
  bool isSubmitClicked = false;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  List<File> selectedFiles = [];
  List<String> uploadedUrls = [];

  void _onFilesSelected(List<File> files) {
    setState(() {
      selectedFiles = files;
    });
  }

  void _submitForm() async {
    setState(() {
      isSubmitClicked != isSubmitClicked;
    });
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString('uid');

      if (uid == null) {
        // Handle error when UID is not found
        print('UID not found in shared preferences');
        return;
      }

      Provider.of<AnimalFormProvider>(context, listen: false).setSecondaryInfo(
        _titleController.text,
        _descriptionController.text,
        _addressLine1Controller.text,
        _cityController.text,
        _stateController.text,
        _pinCodeController.text,
        _mobileNumberController.text,
      );

      // Upload the files
      if (selectedFiles.isNotEmpty) {
        UploadService uploadService = UploadService();
        List<String> urls = await uploadService.uploadFiles(selectedFiles);

        // Update the state with the uploaded URLs and print them
        setState(() {
          uploadedUrls.addAll(urls);
        });
      }

      // Print form data to console
      final provider = Provider.of<AnimalFormProvider>(context, listen: false);
      print('Animal Type: ${provider.animalType}');
      print('Breed: ${provider.breed}');
      print('Age: ${provider.age}');
      print('Weight: ${provider.weight}');
      print('Price: ${provider.price}');
      print('Title: ${provider.title}');
      print('Description: ${provider.description}');
      print('Address Line 1: ${provider.addressLine1}');
      print('City: ${provider.city}');
      print('State: ${provider.state}');
      print('Pin Code: ${provider.pinCode}');
      print('Mobile Number: ${provider.mobileNumber}');
      print('Uploaded Files: $uploadedUrls');

      await UploadService().saveDataToDatabase(
        uid,
        provider.animalType,
        provider.breed,
        provider.age,
        provider.weight,
        provider.price,
        provider.title,
        provider.description,
        provider.addressLine1,
        provider.city,
        provider.state,
        provider.pinCode,
        provider.mobileNumber,
        uploadedUrls,
      );
      SnackbarUtil.showSnackbar(context, 'Animal Uploaded Successfully');
      Navigator.pushReplacementNamed(context, '/home');
      // Save the form data to Firebase or handle it as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Secondary Information",
            style: GoogleFonts.archivoBlack(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Title",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Your Ad Title',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                "Description",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText:
                      'Describe the animal details in brief such as breed, gender, pregnency, etc',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                "Address",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _addressLine1Controller,
                decoration: InputDecoration(
                  hintText: 'Address',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                "City",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'City',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                "State",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  hintText: 'State',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                "Pin Code",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _pinCodeController,
                decoration: InputDecoration(
                  hintText: 'Pin Code',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pin code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                "Mobile Number",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _mobileNumberController,
                decoration: InputDecoration(
                  hintText: 'Mobile No.',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile number';
                  } else if (value.length != 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                "Images & Videos",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange),
              ),
              SizedBox(height: 8),
              FileUploadWidget(onFilesSelected: _onFilesSelected),
              SizedBox(
                height: 5,
              ),
              Text(
                '**Note: Maximum allowed file size is 200mb',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: _submitForm,
                child: isSubmitClicked
                    ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text('Submit',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
