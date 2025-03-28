import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/scores_model.dart';
import 'package:coffee_card/models/user_model.dart';

class CustomScoresModel {
  EventsModel event;
  UserModel user;
  ScoresModel score;


  // Constructor to manually input data
  CustomScoresModel({
    required this.event,
    required this.user,
    required this.score,
    
  });

}