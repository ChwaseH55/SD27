import 'dart:convert';
import 'dart:developer';
import 'package:coffee_card/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

String urlAddress = "http://10.0.2.2:5000";

Future<void> registerUser({
  required BuildContext context,
  required String username,
  required String email,
  required String password,
  required String firstName,
  required String lastName,
}) async {
  try {
    final url = Uri.parse('$urlAddress/api/auth/register');

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
    final url = Uri.parse('$urlAddress/api/auth/login');
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
      String userId =
          data['user']['id'].toString(); // Assuming 'userID' exists in response

      // Save userID to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userID', userId);

      log('User ID cached: $userId');
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
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userID');
}

Future<void> logoutUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('userID');
  log('User logged out, ID removed');
}
