import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class UploadService {
  final String uploadUrl = 'https://api.greatshark.tech/upload.php';
  final String apiKey = 'qyzyPsFd7Ft7yoaWYBjZ3ksvYBgwf3yG';

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
    request.headers['APIKEY'] = apiKey;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);
      if (jsonResponse['url'] != null) {
        return jsonResponse['url'];
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
    String? title,
    String? description,
    String? addressLine1,
    String? city,
    String? state,
    String? pinCode,
    String? mobileNumber,
    List<String> uploadedUrls,
  ) async {
    // Your database save logic here
    // For example, if using Firebase:
    await FirebaseFirestore.instance.collection('animals').add({
      'uid': uid,
      'animalType': animalType,
      'breed': breed,
      'age': age,
      'weight': weight,
      'price': price,
      'title': title,
      'description': description,
      'addressLine1': addressLine1,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'mobileNumber': mobileNumber,
      'uploadedUrls': uploadedUrls,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
