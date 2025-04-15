import 'dart:developer';

import 'package:coffee_card/api_request/auth_request.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/postwithreplies_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/models/likes_model.dart';

class PostProvider extends ChangeNotifier {
  PostResponse? _postDetails;
  final Map<String, UserModel> _replyUsers = {};
  UserModel? _postUser;
  UserModel? _cacheUser;
  String? _roleid;
  Map<int, int> _likes = {};
  bool _isLoading = true;

  PostResponse? get postDetails => _postDetails;
  Map<String, UserModel> get replyUsers => _replyUsers;
  UserModel? get cacheUser => _cacheUser;
  String? get roleid => _roleid;
  UserModel? get postUser => _postUser;
  Map<int, int> get likes => _likes;
  bool get isLoading => _isLoading;

  Future<void> fetchPostDetails(String postId) async {
    _isLoading = true;

    try {
      _postDetails = await getPostWithReplies(postId: postId);
      if (_postDetails?.post != null) {
        _postUser =
            await getSingleUser(userId: _postDetails!.post!.userid.toString());
        var temp = await getUserID();
        _cacheUser = await getSingleUser(userId: temp!);
        _roleid = await getRoleId();
        _likes = await getLikes(postId: postId, replyId: null);
        for (var reply in _postDetails!.replies!) {
          replyUsers[reply.replyid.toString()] = await getSingleUser(
              userId: reply.userid.toString()); // or batch fetch
        }
      }
    } catch (e) {
      _postDetails = null;
      _postUser = null;
      _likes = {};
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteReplyAndRefresh(String replyId, String postId) async {
    await deleteReply(
        replyId: replyId); // Ensure delete completes before fetching
    await fetchPostDetails(postId); // Refresh the post data
    notifyListeners(); // Force UI update
  }

  Future<void> addReplyAndRefresh(
      String postId, String text, String userId) async {
    await addReply(postId: postId, content: text, userId: userId);
    await fetchPostDetails(postId); // Refresh the post data
    notifyListeners(); // Force UI update
  }

  Future<void> editReplyAndRefresh(
      String replyId, String text, String postId) async {
    await updateReply(
        replyId: replyId,
        content: text); // Ensure delete completes before fetching
    await fetchPostDetails(postId); // Refresh the post data
    notifyListeners(); // Force UI update
  }
}
