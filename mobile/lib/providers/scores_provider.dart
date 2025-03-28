import 'package:coffee_card/api_request/announcement_request.dart';
import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';

class ScoresProvider extends ChangeNotifier {
  List<UserModel> _users = [];
  bool _isLoading = true;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> getUsers() async {
    _isLoading = true;
    //notifyListeners();

    try {
      _users = await getAllUsers();
    } catch (e) {
      _users;
    }

    _isLoading = false;
    notifyListeners();
  }
}

