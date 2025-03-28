import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  List<UserModel> _users = [];
  bool _isLoading = true;

  UserModel? get user => _user;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> getUsers() async {
    _isLoading = true;
    //notifyListeners();

    try {
      _users = await getAllUsers();
      String? temp = await getUserID();
      _user = await getSingleUser(userId: temp!);
    } catch (e) {
      _users = [];
      _user = null;
    }
    _isLoading = false;
    notifyListeners();
  }
}
