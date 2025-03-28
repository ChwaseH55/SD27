import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils.dart';
import 'dart:developer' as dev;
import '../models/cart_item_model.dart';

const storage = FlutterSecureStorage();

Future<List<Map<String, dynamic>>> getShopItems(String userId) async {
  final token = await storage.read(key: 'token');
  dev.log('ShopRequest - Token: $token');
  if (token == null) throw Exception('Not authenticated');

  final response = await http.get(
    Uri.parse('${Utils.apiUrl}/stripe/productlist?userId=$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data);
  }
  throw Exception('Failed to load shop items');
}

Future<bool> purchaseShopItem(List<Map<String, dynamic>> cartItems) async {
  final token = await storage.read(key: 'token');
  if (token == null) throw Exception('Not authenticated');

  final response = await http.post(
    Uri.parse('${Utils.apiUrl}/shop/purchase'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode({'items': cartItems}),
  );

  return response.statusCode == 200;
}

Future<String?> createStripeCheckoutSession({
  required List<Map<String, dynamic>> cartItems,
  required String userId,
}) async {
  try {
    final token = await storage.read(key: 'token');
    if (token == null) throw Exception('Not authenticated');

    final requestBody = {
      'items': cartItems,
      'userId': userId,
    };
    
    dev.log('Creating checkout session with body: ${jsonEncode(requestBody)}');

    final response = await http.post(
      Uri.parse('${Utils.apiUrl}/stripe/create-checkout-session'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    dev.log('Checkout session response status: ${response.statusCode}');
    dev.log('Checkout session response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    } else {
      dev.log('Checkout session error: ${response.body}');
      throw Exception('Failed to create checkout session');
    }
  } catch (e) {
    dev.log('Error creating checkout session: $e');
    return null;
  }
} 