import 'package:coffee_card/api_request/auth_request.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/models/likes_model.dart';

class ReplyProvider extends ChangeNotifier {
  UserModel? _user;
  Map<int,int> _likes = {};
  bool _isLoading = true;
  String? _userid;
  String? _roleid;

  UserModel? get user => _user;
  Map<int,int> get likes => _likes;
  bool get isLoading => _isLoading;
  String? get userId => _userid;
  String? get roleid => _roleid;

  ReplyProvider(String replyId, String userId) {
    fetchReplyDetails(replyId, userId);
  }

  Future<void> fetchReplyDetails(String replyId, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _likes = await getLikes(postId: null, replyId: replyId);

      _user = await getUser(userId: userId);
      _userid = await getUserID();
            _roleid = await getRoleId();
      
    } catch (e) {
      _user = null;
      _likes = {};
    }

    _isLoading = false;
    notifyListeners();
  }
}
