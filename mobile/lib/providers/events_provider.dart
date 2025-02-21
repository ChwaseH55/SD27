import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:flutter/material.dart';

class EventsProvider extends ChangeNotifier {
  List<EventsModel> _events = [];
  String? _userid;
  bool _isLoading = true;

  List<EventsModel> get events => _events;
  String? get userId => _userid;
  bool get isLoading => _isLoading;

  Future<void> fetchEvents() async {
    _isLoading = true;
    //notifyListeners();

    try {
      _events = await getAllEvents();
      _userid = await getUserID();
    } catch (e) {
      _events = [];
      _userid = '';
    }

    _isLoading = false;
    notifyListeners();
  }
}
