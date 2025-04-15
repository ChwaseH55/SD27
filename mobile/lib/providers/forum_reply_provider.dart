import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/models/postwithreplies_model.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/models/likes_model.dart';

class ReplyProvider extends ChangeNotifier {
  final Map<int, UserModel> _users = {};
  final Map<int, Map<int, int>> _likes = {}; // replyId -> likes map
  bool _isLoading = true;
  String? _userid;
  String? _roleid;

  Map<int, UserModel> get users => _users;
  Map<int, Map<int, int>> get likes => _likes;
  bool get isLoading => _isLoading;
  String? get userId => _userid;
  String? get roleId => _roleid;

  Future<void> fetchReplyDetailsList(List<ReplyModel> replies) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userid = await getUserID();
      _roleid = await getRoleId();

      for (var reply in replies) {
        final user = await getSingleUser(userId: reply.userid.toString());
        final likeMap = await getLikes(postId: null, replyId: reply.replyid.toString());

        _users[reply.replyid!] = user;
        _likes[reply.replyid!] = likeMap;
      }
    } catch (e) {
      // Handle errors individually if needed
    }

    _isLoading = false;
    notifyListeners();
  }
  
}
