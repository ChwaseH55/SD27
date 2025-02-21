import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> getUserName(String userId) async {
    _isLoading = true;
    //notifyListeners();

    try {
      _user = await getUser(userId: userId);
    } catch (e) {
      _user;
    }

    _isLoading = false;
    notifyListeners();
  }
}
