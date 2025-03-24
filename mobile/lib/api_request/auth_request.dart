import 'dart:convert';
import 'dart:developer';
import 'package:coffee_card/api_request/config.dart';
import 'package:coffee_card/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

String urlAddress = "http://11.22.13.70:5000/api/auth";
const FlutterSecureStorage storage = FlutterSecureStorage();
Dio dio = ApiService.dio;

Future<void> registerUser({
  required BuildContext context,
  required String username,
  required String email,
  required String password,
  required String firstName,
  required String lastName,
}) async {
  try {
    final url = Uri.parse('/auth/register');

    final response = await post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "username": username,
        "email": email,
        "password": password,
        "firstName": firstName,
        "lastName": lastName,
      }),
    );

    if (response.statusCode == 200) {
      // Navigate to home screen on success
      navigatorKey.currentState?.pushNamed('/mainMenu');
      log('Register successfully');
    } else {
      log('Error with register');
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<void> loginUser({
  required String username,
  required String password,
  required BuildContext context,
}) async {
  try {
    final url = Uri.parse('$urlAddress/login');
    final response = await post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      // Assuming 'userID' exists in response

      // Save userID to shared preferences
      await storage.write(key: 'userId', value: data['user']['id'].toString());
      await storage.write(key: 'userRole', value: data['user']['role'].toString());
      await storage.write(key: 'token', value: data['token'].toString());
      String? userId = await storage.read(key: 'userId');
       String? role = await storage.read(key: 'userRole');
      log('User ID cached: $userId');
      log('User ID cached: $role');
      log('Login successfully');

      if (context.mounted) Navigator.pushNamed(context, '/mainMenu');
    } else {
      log('Login failed');
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<String?> getUserID() async {
  return await storage.read(key: 'userId');
}

Future<String?> getRoleId() async {
  return await storage.read(key: 'userRole');
}

Future<void> logoutUser() async {
  await storage.delete(key: 'userId');
  await storage.delete(key: 'token');
  log('User logged out, ID removed');
}
