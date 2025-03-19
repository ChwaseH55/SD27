import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

const String apiBaseUrl = '/api'; // Replace with your API URL

class User {
  final String id;
  User(this.id);
}

class StoreState extends ChangeNotifier {
  User? user;
  List<dynamic> cartItems = [];
  List<dynamic> products = [];
  bool loading = true;

  Future<void> fetchProducts(String userId) async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/stripe/productlist?userId=$userId'));
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        products = json.decode(response.body);
        loading = false;
        notifyListeners();
      } else {
        print('Failed to load products: ${response.statusCode}');
        loading = false;
        notifyListeners();
      }
    } catch (error) {
      print('Error fetching products: $error');
      loading = false;
      notifyListeners();
    }
  }

  Future<void> handleCheckout(String userId) async {
    final lineItems = cartItems.map((item) => {
          'price': item['priceId'],
          'quantity': item['quantity'],
          'name': item['name'],
        }).toList();

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/stripe/create-checkout-session'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'cartItems': lineItems, 'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['url'] != null) {
          final Uri url = Uri.parse(data['url']);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Could not launch $url');
          }
        } else {
          print('Error: No URL returned from Stripe session creation.');
        }
      } else {
        print('Error creating checkout session: ${response.statusCode}');
      }
    } catch (error) {
      print('Error creating checkout session: $error');
    }
  }

  void addToCart(dynamic product) {
    final existingItem = cartItems.firstWhere((item) => item['id'] == product['id'], orElse: () => null);
    if (existingItem != null) {
      existingItem['quantity']++;
    } else {
      cartItems.add({...product, 'quantity': 1});
    }
    notifyListeners();
  }
}