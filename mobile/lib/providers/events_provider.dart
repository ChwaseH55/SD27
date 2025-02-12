import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:flutter/material.dart';

class EventsProvider extends ChangeNotifier {
  List<EventsModel> _events = [];
  bool _isLoading = true;

  List<EventsModel> get events => _events;
  bool get isLoading => _isLoading;

  Future<void> fetchEvents() async {
    _isLoading = true;
    //notifyListeners();

    try {
      _events = await getAllEvents();
    } catch (e) {
      _events = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
