import 'package:coffee_card/api_request/announcement_request.dart';
import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:flutter/material.dart';

class AnnouncementProvider extends ChangeNotifier {
  List<AnnouncementModel> _announcements = [];
  String? _userid;
  bool _isLoading = true;

  List<AnnouncementModel> get announcements => _announcements;
  String? get userId => _userid;
  bool get isLoading => _isLoading;

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    //notifyListeners();

    try {
      _announcements = await getAllAnnouncements();
      _userid = await getUserID();
    } catch (e) {
      _announcements = [];
      _userid = '';
    }

    _isLoading = false;
    notifyListeners();
  }
}
