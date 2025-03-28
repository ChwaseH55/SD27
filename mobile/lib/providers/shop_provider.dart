import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../api_request/shop_request.dart';
import 'user_provider.dart';
import '../models/cart_item_model.dart';

class ShopProvider with ChangeNotifier {
  final UserProvider _userProvider;
  
  ShopProvider(this._userProvider);

  List<Map<String, dynamic>> _items = [];
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get items => _items;
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      dev.log('ShopProvider - Starting fetchItems');
      
      final userId = 1; //_userProvider.user?.id;
      dev.log('ShopProvider - User ID: $userId');
      
      if (userId == null) {
        _error = 'User not found';
        dev.log('ShopProvider - User not found error');
        _isLoading = false;
        notifyListeners();
        return;
      }

      dev.log('ShopProvider - Fetching shop items');
      _items = await getShopItems("1");
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
      _cartItems.add(CartItem(
        id: product['id'],
        name: product['name'],
        priceId: product['priceId'],
        price: product['price'].toDouble(),
      ));
    } else {
      existingItem.quantity++;
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
      final userId = 1; //_userProvider.user?.id;
      if (userId == null) {
        throw Exception('User not found');
      }

      final lineItems = _cartItems.map((item) => item.toJson()).toList();
      final checkoutUrl = await createStripeCheckoutSession(
        cartItems: lineItems,
        userId: userId.toString(),
      );
      return checkoutUrl;
    } catch (e) {
      dev.log('ShopProvider - Checkout Error: $e');
      return null;
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