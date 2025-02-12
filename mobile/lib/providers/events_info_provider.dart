import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:flutter/material.dart';

class EventsInfoProvider extends ChangeNotifier {
  EventsModel? _eventsDetails;
  bool _isLoading = true;

  EventsModel? get eventsDetails => _eventsDetails;
  bool get isLoading => _isLoading;

  Future<void> fetchEventDetails(String id) async {
    _isLoading = true;

    try {
      _eventsDetails = await getEventById(id);
    } catch (e) {
      _eventsDetails = null;
    }
    _isLoading = false;
    notifyListeners();
  }
}
