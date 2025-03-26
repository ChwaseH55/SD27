import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';

class EventsInfoProvider extends ChangeNotifier {
  EventsModel? _eventsDetails;
  UserModel? _creationUser;
  String? _userid;
  String? _roleid;
  bool _isLoading = true;

  EventsModel? get eventsDetails => _eventsDetails;
   UserModel? get creationUser => _creationUser;
  bool get isLoading => _isLoading;
   String? get userId => _userid;
  String? get roleid => _roleid;

  Future<void> fetchEventDetails(String id) async {
    _isLoading = true;

    try {
      _eventsDetails = await getEventById(id);
      _creationUser = await getSingleUser(userId: eventsDetails!.createdbyuserid.toString());
      _userid = await getUserID();
      _roleid = await getRoleId();
    } catch (e) {
      _eventsDetails = null;
      _creationUser = null;
    }
    _isLoading = false;
    notifyListeners();
  }
}
