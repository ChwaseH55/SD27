import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:flutter/material.dart';

class EventsProvider extends ChangeNotifier {
  List<EventsModel> _events = [];
  final Map<int,bool> _isRegList = {};
  List<EventsModel> _registeredevents = [];
  String? _userid;
  String? _roleid;
  bool _isLoading = true;

  List<EventsModel> get events => _events;
  Map<int,bool> get isRegList => _isRegList;
   List<EventsModel> get registeredevents => _registeredevents;
  String? get userId => _userid;
  String? get roleid => _roleid;
  bool get isLoading => _isLoading;

  Future<void> fetchEvents() async {
    _isLoading = true;
    //notifyListeners();

    try {
      _events = await getAllEvents();
      _userid = await getUserID();
      for(var event in _events ) {
        _isRegList[event.eventid!] = await isUserRegisteredForEvent(event.eventid.toString(), userId!);
      }
      _roleid = await getRoleId();
      _registeredevents = await getUserRegisteredEvents(userId!);
    } catch (e) {
      _events = [];
      _userid = '';
      _registeredevents = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
