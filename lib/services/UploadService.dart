import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class UploadService {
  // Updated endpoint and Bearer Token
  final String uploadUrl = 'https://api.ckgoat.greatshark.tech/storage/upload/';
  final String bearerToken =
      'gCW0z7uTiZqbNwoYQsDvE2gAPxdHfXciazPmCzPneXpn444glZ'; // Your actual Bearer token

  Future<List<String>> uploadFiles(List<File> files) async {
    List<String> uploadedUrls = [];

    for (File file in files) {
      String? fileUrl = await uploadFile(file);
      if (fileUrl != null) {
        uploadedUrls.add(fileUrl);
      }
    }

    return uploadedUrls;
  }

  Future<String?> uploadFile(File file) async {
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

    // Use Bearer Token for authentication
    request.headers['Authorization'] = 'Bearer $bearerToken';
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    if (response.statusCode == 201) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);
      if (jsonResponse['file_urls'] != null) {
        return jsonResponse['file_urls'][0];
      } else {
        print('Error: ${jsonResponse['error']}');
        return null;
      }
    } else {
      print('Error: Server responded with status code ${response.statusCode}');
      return null;
    }
  }

  Future<void> saveDataToDatabase(
    String uid,
    String? animalType,
    String? breed,
    int? age,
    double? weight,
    double? price,
    String? addressLine1,
    String? city,
    String? state,
    String? pinCode,
    String? mobileNumber,
    List<String> uploadedUrls,
  ) async {
    // Create a map for the data to be uploaded
    Map<String, dynamic> animalData = {
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Only add non-null values to the map
    if (animalType != null) animalData['animalType'] = animalType;
    if (breed != null) animalData['breed'] = breed;
    if (age != null) animalData['age'] = age;
    if (weight != null) animalData['weight'] = weight;
    if (price != null) animalData['price'] = price;
    if (addressLine1 != null) animalData['addressLine1'] = addressLine1;
    if (city != null) animalData['city'] = city;
    if (state != null) animalData['state'] = state;
    if (pinCode != null) animalData['pinCode'] = pinCode;
    if (mobileNumber != null) animalData['mobileNumber'] = mobileNumber;
    if (uploadedUrls.isNotEmpty) animalData['uploadedUrls'] = uploadedUrls;

    // Save the data to the database (Firebase Firestore example)
    await FirebaseFirestore.instance.collection('animals').add(animalData);
  }
}
