import 'dart:math';
import 'dart:developer' as dev;
import 'dart:convert';

import 'package:flutter/material.dart';
import '../screens/checkout_webview_screen.dart'; // Adjust the path as needed
import '../api_request/shop_request.dart';
import '../api_request/auth_request.dart';
import 'user_provider.dart';
import '../models/cart_item_model.dart';

class ShopProvider with ChangeNotifier {
  final UserProvider _userProvider;
  
  ShopProvider(this._userProvider);

  List<Map<String, dynamic>> _items = [];
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  String? _userid;
  String? _roleid;

  List<Map<String, dynamic>> get items => _items;
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userid;
  String? get roleid => _roleid;

  Future<void> fetchItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      dev.log('ShopProvider - Starting fetchItems');
      
      _userid = await getUserID();
      _roleid = await getRoleId();
      dev.log('ShopProvider - User ID: $_userid');
      
      if (_userid == null) {
        _error = 'User not found';
        dev.log('ShopProvider - User not found error');
        _isLoading = false;
        notifyListeners();
        return;
      }

      dev.log('ShopProvider - Fetching shop items');
      _items = await getShopItems(_userid!);
      
      // Log the structure of the first item to debug
      if (_items.isNotEmpty) {
        dev.log('ShopProvider - First item structure: ${_items[0]}');
        dev.log('ShopProvider - First item name: ${_items[0]['name']}');
        dev.log('ShopProvider - First item price: ${_items[0]['price']}');
        dev.log('ShopProvider - First item priceId: ${_items[0]['priceId']}');
      }
      
      dev.log('ShopProvider - Items fetched successfully');
    } catch (e) {
      _error = e.toString();
      dev.log('ShopProvider - Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      dev.log('ShopProvider - Loading complete');
    }
  }

  void addToCart(Map<String, dynamic> product) {
    dev.log('Adding to cart - Product structure: $product');
    dev.log('Adding to cart - Product name: ${product['name']}');
    dev.log('Adding to cart - Product price: ${product['price']}');
    dev.log('Adding to cart - Product priceId: ${product['priceId']}');
    
    final existingItem = _cartItems.firstWhere(
      (item) => item.id == product['id'],
      orElse: () => CartItem(
        id: '',
        name: '',
        priceId: '',
        price: 0,
      ),
    );

    if (existingItem.id.isEmpty) {
      final newItem = CartItem(
        id: product['id'],
        name: product['name'] ?? 'Unknown Product',
        priceId: product['priceId'] ?? product['price_id'],
        price: (product['price'] ?? 0).toDouble(),
      );
      dev.log('Created new cart item: ${newItem.name}');
      _cartItems.add(newItem);
    } else {
      existingItem.quantity++;
      dev.log('Updated existing cart item: ${existingItem.name}');
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final item = _cartItems.firstWhere((item) => item.id == productId);
    item.quantity = quantity;
    if (quantity <= 0) {
      removeFromCart(productId);
    }
    notifyListeners();
  }

  Future<String?> createCheckoutSession() async {
  try {
    if (_userid == null) {
      throw Exception('User not found');
    }

    if (_cartItems.isEmpty) {
      throw Exception('Cart is empty');
    }

    dev.log('Creating checkout with ${_cartItems.length} items');
    for (var item in _cartItems) {
      dev.log('Item: ${item.name}, Price: ${item.price}, Quantity: ${item.quantity}, PriceId: ${item.priceId}');
    }

    final lineItems = _cartItems.map((item) => item.toJson()).toList();
    dev.log('Line items: ${jsonEncode(lineItems)}');
    
    final checkoutUrl = await createStripeCheckoutSession(
      cartItems: lineItems,
      userId: _userid!,
    );
    return checkoutUrl;
  } catch (e) {
    dev.log('ShopProvider - Checkout Error: $e');
    return null;
  }
}

  Future<bool> launchCheckout(BuildContext context) async {
    try {
      if (_userid == null) {
        throw Exception('User not found');
      }

      if (_cartItems.isEmpty) {
        throw Exception('Cart is empty');
      }

      dev.log('Creating checkout with ${_cartItems.length} items');
      for (var item in _cartItems) {
        dev.log('Item: ${item.name}, Price: ${item.price}, Quantity: ${item.quantity}, PriceId: ${item.priceId}');
      }

      final lineItems = _cartItems.map((item) => item.toJson()).toList();
      dev.log('Line items: ${jsonEncode(lineItems)}');
      
      final checkoutUrl = await createStripeCheckoutSession(
        cartItems: lineItems,
        userId: _userid!,
      );

      if (checkoutUrl == null) {
        return false;
      }

      if (!context.mounted) {
        return false;
      }
      
      // Navigate to the WebView checkout
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => CheckoutWebViewScreen(checkoutUrl: checkoutUrl),
        ),
      );
      
      // Clear cart if payment was successful
      if (result == true) {
        clearCart();
      }
      
      return result ?? false;
    } catch (e) {
      dev.log('ShopProvider - Checkout Error: $e');
      return false;
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<bool> purchaseItem() async {
    try {
      final lineItems = _cartItems.map((item) => item.toJson()).toList();
      return await purchaseShopItem(lineItems);
    } catch (e) {
      dev.log('ShopProvider - Purchase Error: $e');
      return false;
    }
  }
}