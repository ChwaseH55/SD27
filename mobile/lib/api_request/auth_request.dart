import 'dart:convert';
import 'dart:developer';
import 'package:coffee_card/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
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

      log(data['token']);
      log('Login successfully');
      if(context.mounted) Navigator.pushNamed(context, '/mainMenu');
    } else {
      log('failed');
    }
  } catch (e) {
    log(e.toString());
    
  }
}
