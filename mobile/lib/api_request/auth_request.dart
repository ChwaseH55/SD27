import 'dart:convert';
import 'dart:developer';
import 'package:coffee_card/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> registerUser({
  required BuildContext context,
  required String username,
  required String email,
  required String password,
  required String firstName,
  required String lastName,
}) async {
  final url = Uri.parse('http://localhost:5000/api/auth/register');

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
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
  } else {
   log('Error with register');
  }
}

Future<void> loginUser({
  required BuildContext context,
  required String username,
  required String password,
}) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/auth/login');

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "username": username,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    // Navigate to home screen on success
   if (context.mounted) Navigator.pushNamed(context, '/mainMenu');
  } else {
   log('Error with login');
  }
}

