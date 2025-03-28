import 'package:coffee_card/api_request/announcement_request.dart';
import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/api_request/scores_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:coffee_card/models/custom_scores_model.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/scores_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';

class ScoresAdminProvider extends ChangeNotifier {
  List<UserModel> _users = [];
  List<UserModel> _adminusers = [];
  List<CustomScoresModel> _custScore = [];

  bool _isLoading = true;

  List<UserModel> get users => _users;
  List<UserModel> get adminusers => _adminusers;
  List<CustomScoresModel> get custScore => _custScore;
  bool get isLoading => _isLoading;

  ScoresAdminProvider(String replyId, String userId) {
    getScores(replyId, userId);
  }

  Future<void> getScores(String topic, String id) async {
    _isLoading = true;
    //notifyListeners();

    try {
      _users = await getAllUsers();
      _adminusers = _users
          .where((user) =>
              user.roleid == 4 || user.roleid == 5 || user.roleid == 6)
          .toList();
      if (topic == 'player') {
        var temp = (await getPlayerScores(id))!;
        _custScore = await makeScores(temp);
      } else if (topic == 'admin') {
        var temp = (await getScoresAdmin(id))!;
        _custScore = await makeScores(temp);
      } else if (topic == 'all') {
        var temp = (await getAllScores())!;
        _custScore = await makeScores(temp);
      } else if (topic == 'pending') {
        var temp = (await getPendingScores())!;
        _custScore = await makeScores(temp);
      } else if (topic == 'denied') {
        var temp = (await getDeniedScores())!;
        _custScore = await makeScores(temp);
      } else if (topic == 'approved') {
        var temp = (await getApprovedScores())!;
        _custScore = await makeScores(temp);
      }
    } catch (e) {
      _users;
    }

    _isLoading = false;
    notifyListeners();
  }
}

Future<List<CustomScoresModel>> makeScores(List<ScoresModel> scores) async {
  List<CustomScoresModel> res = [];
  for (ScoresModel score in scores) {
    var event = await getEventById(score.eventid.toString());
    var user = await getSingleUser(userId: score.userid.toString());
    var newScore = await getScoreById(score.scoreid.toString());
    CustomScoresModel model =
        CustomScoresModel(event: event, user: user, score: newScore);
    res.add(model);
  }
  return res;
}
