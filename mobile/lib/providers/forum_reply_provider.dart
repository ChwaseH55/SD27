import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/models/likes_model.dart';

class ReplyProvider extends ChangeNotifier {
  UserModel? _user;
  int _likesCount = 0;
  bool _isLoading = true;

  UserModel? get user => _user;
  int get likesCount => _likesCount;
  bool get isLoading => _isLoading;

  ReplyProvider(String replyId, String userId) {
    fetchReplyDetails(replyId, userId);
  }

  Future<void> fetchReplyDetails(String replyId, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final likes = await getLikesWithReplyId(replyId);
      _likesCount = likes.length;
      _user = await getUser(userId: userId);
      
    } catch (e) {
      _user = null;
      _likesCount = 0;
    }

    _isLoading = false;
    notifyListeners();
  }
}
