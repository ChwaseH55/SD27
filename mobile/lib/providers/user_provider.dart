import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  List<UserModel> _users = [];
  bool _isLoading = true;

  UserModel? get user => _user;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> getUsers() async {
    _isLoading = true;
    dev.log('UserProvider - Starting getUsers');
    notifyListeners();

    try {
      _users = await getAllUsers();
      dev.log('UserProvider - Got all users');
      String? temp = await getUserID();
      dev.log('UserProvider - Got user ID from storage: $temp');
      _user = await getSingleUser(userId: temp!);
      dev.log('UserProvider - Got single user: ${_user?.id}');
    } catch (e) {
      dev.log('UserProvider - Error loading users: $e');
      _users = [];
      _user = null;
    }
    _isLoading = false;
    notifyListeners();
    dev.log('UserProvider - Finished loading users');
  }
}
