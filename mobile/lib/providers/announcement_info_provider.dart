import 'package:coffee_card/api_request/announcement_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';

class AnnouncementInfoProvider extends ChangeNotifier {
  AnnouncementModel? _announcementDetails;
  UserModel? _creationUser;
  bool _isLoading = true;

  AnnouncementModel? get announcementDetails => _announcementDetails;
   UserModel? get creationUser => _creationUser;
  bool get isLoading => _isLoading;

  Future<void> fetchAnnouncementDetails(String id) async {
    _isLoading = true;

    try {
      _announcementDetails = await getAnnouncementById(id);
      _creationUser = await getUser(userId: _announcementDetails!.userid.toString());
    } catch (e) {
      _announcementDetails = null;
      _creationUser = null;
    }
    _isLoading = false;
    notifyListeners();
  }
}
