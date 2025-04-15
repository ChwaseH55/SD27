import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/announcement_request.dart';
import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/announcement_model.dart';

class AnnouncementProvider extends ChangeNotifier {
  List<AnnouncementModel> _announcements = [];
  final Map<int, String> _postUsers = {};
  String? _userId;
  String? _roleId;
  bool _isLoading = true;

  List<AnnouncementModel> get announcements => _announcements;
  Map<int, String> get postUsers => _postUsers;
  String? get userId => _userId;
  String? get roleId => _roleId;
  bool get isLoading => _isLoading;

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    notifyListeners();

    try {
      _announcements = await getAllAnnouncements();
      _postUsers.clear();

      // Fetch all usernames in parallel
      await Future.wait(_announcements.map((ann) async {
        if (ann.announcementid != null && ann.userid != null) {
          final user = await getSingleUser(userId: ann.userid.toString());
          _postUsers[ann.announcementid!] = user.username;
        }
      }));

      // Fetch current user data
      final userFuture = getUserID();
      final roleFuture = getRoleId();
      final results = await Future.wait([userFuture, roleFuture]);

      _userId = results[0] as String?;
      _roleId = results[1] as String?;
    } catch (e) {
      _announcements = [];
      _postUsers.clear();
      _userId = null;
      _roleId = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  List<AnnouncementModel> getFilteredAnnc(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _announcements.where((ann) {
      return ann.title?.toLowerCase().contains(lowercaseQuery) ?? false;
    }).toList();
  }
}
