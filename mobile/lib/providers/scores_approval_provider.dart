import 'package:flutter/material.dart';
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

class ScoresAdminProvider extends ChangeNotifier {
  final List<UserModel> _users = [];
  final List<UserModel> _adminusers = [];
  final List<CustomScoresModel> _custScore = [];

  bool _isLoading = true;

  List<UserModel> get users => _users;
  List<UserModel> get adminusers => _adminusers;
  List<CustomScoresModel> get custScore => _custScore;
  bool get isLoading => _isLoading;

  ScoresAdminProvider(String replyId, String userId) {
    loadScores(replyId, userId);
  }

  Future<void> loadScores(String topic, String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allUsers = await getAllUsers();
      _users.clear();
      _users.addAll(allUsers);

      _adminusers.clear();
      _adminusers.addAll(
        allUsers.where((u) => [4, 5, 6].contains(u.roleid)),
      );

      List<ScoresModel> scores;

      switch (topic) {
        case 'player':
          scores = await getPlayerScores(id) ?? [];
          break;
        case 'admin':
          scores = await getScoresAdmin(id) ?? [];
          break;
        case 'all':
          scores = await getAllScores() ?? [];
          break;
        case 'pending':
          scores = await getPendingScores() ?? [];
          break;
        case 'denied':
          scores = await getDeniedScores() ?? [];
          break;
        case 'approved':
          scores = await getApprovedScores() ?? [];
          break;
        default:
          scores = [];
      }

      final custom = await makeScores(scores);
      _custScore
        ..clear()
        ..addAll(custom);
    } catch (e) {
      debugPrint('Error loading scores: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}

Future<List<CustomScoresModel>> makeScores(List<ScoresModel> scores) async {
  return Future.wait(scores.map((score) async {
    final event = await getEventById(score.eventid.toString());
    final user = await getSingleUser(userId: score.userid.toString());
    final fullScore = await getScoreById(score.scoreid.toString());

    return CustomScoresModel(
      event: event,
      user: user,
      score: fullScore,
    );
  }));
}
