import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';

class EventsInfoProvider extends ChangeNotifier {
  EventsModel? _eventsDetails;
  UserModel? _creationUser;
  bool _isLoading = true;

  EventsModel? get eventsDetails => _eventsDetails;
   UserModel? get creationUser => _creationUser;
  bool get isLoading => _isLoading;

  Future<void> fetchEventDetails(String id) async {
    _isLoading = true;

    try {
      _eventsDetails = await getEventById(id);
      _creationUser = await getUser(userId: eventsDetails!.createdbyuserid.toString());
    } catch (e) {
      _eventsDetails = null;
      _creationUser = null;
    }
    _isLoading = false;
    notifyListeners();
  }
}
