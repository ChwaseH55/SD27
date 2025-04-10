import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:coffee_card/models/user_model.dart';

String urlAddress = "https://sd27-87d55.web.app/api/users";
String devAddress = "http://11.22.13.70:5000/api/users";
const FlutterSecureStorage _storage = FlutterSecureStorage();

Future<UserModel> getSingleUser({required String userId}) async {
  try {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$urlAddress/$userId');
    final response =
        await get(url, headers: {'Authorization': 'Bearer ${token!}'});

    if (response.statusCode == 200) {
      final res = UserModel.fromJson(json.decode(response.body));
      return res;
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    log('Stack Trace: $stackTrace');
    throw Exception('Error fetching user: $e');
  }
}

Future<List<UserModel>> getAllUsers() async {
  try {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$urlAddress/');
    final response =
        await get(url, headers: {'Authorization': 'Bearer ${token!}'});

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch user: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching users: $e');
  }
}

Future<bool> updateUserInfo(String? username, String? firstName,
    String? lastname, FilePickerResult? profilePicture,
    {required String id}) async {
  try {
    var url = Uri.parse("$urlAddress/$id");

    final token = await _storage.read(key: 'token');

    if (profilePicture == null) {
      log("No file selected");
    } else {
      for (var element in profilePicture.files) {
        log(element.name);
      }
    }
    File file = File(profilePicture!.files.single.path!);

    String fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${profilePicture.files.single.name}";

    Reference storageRef =
        FirebaseStorage.instance.ref().child("profile_pictures/$id/$fileName");

    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot snapshot = await uploadTask;

    String downloadUrl = await snapshot.ref.getDownloadURL();
    log("File uploaded! Download URL: $downloadUrl");

    final response = await put(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${token!}'
      },
      body: jsonEncode({
        "username": username,
        "firstName": firstName,
        "lastname": lastname,
        "profilePicture": downloadUrl
      }),
    );

    // Handle response
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      log("Success: ${jsonResponse['message']}");
      return true;
    } else {
      log("Error: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    throw Exception("Error updating score: $e");
  }
}
