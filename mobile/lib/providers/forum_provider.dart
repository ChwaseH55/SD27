import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/models/post_model.dart';

class ForumProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = true;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> fetchPosts() async {
    _isLoading = true;
    //notifyListeners();

    try {
      _posts = await getAllPosts();
    } catch (e) {
      _posts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<int> getLikesCount(String postId) async {
    try {
      final likes = await getLikesWithPostId(postId: postId);
      return likes;
    } catch (e) {
      return 0;
    }
  }
}
