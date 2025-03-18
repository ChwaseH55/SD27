import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/models/post_model.dart';

class ForumProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = true;
   String? _cacheUser;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get cacheUser => _cacheUser;

  Future<void> fetchPosts() async {
    _isLoading = true;
    //notifyListeners();

    try {
      _posts = await getAllPosts();
      _cacheUser = await getUserID();
    } catch (e) {
      _posts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<int,int>> getLikesCount(String postId) async {
    try {
      final likes = await getLikes(postId: postId, replyId: null);
      return likes;
    } catch (e) {
      return {};
    }
  }
}
