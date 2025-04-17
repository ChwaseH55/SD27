import 'package:coffee_card/api_request/announcement_request.dart';
import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/scores_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';

class LeaderboardProvider extends ChangeNotifier {
  Map<int, UserModel> _users = {};
  bool _isLoading = true;

  Map<int, UserModel> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> getUsers() async {
    _isLoading = true;
    //notifyListeners();

    try {
      List<ScoresModel>? tempScores = [
    ScoresModel(userid: 1, score: 23),
    ScoresModel(userid: 1, score: 33),
    ScoresModel(userid: 1, score: 3)
  ];
      for (var n in tempScores) {
        _users[n.userid!] = await getSingleUser(userId: '${n.userid}');
      }
      
    } catch (e) {
      _users;
    }

    _isLoading = false;
    notifyListeners();
  }
}

