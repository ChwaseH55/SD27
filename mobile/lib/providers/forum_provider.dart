import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/models/post_model.dart';

class ForumProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  final Map<int,Map<int,int>> _likes = {};
  bool _isLoading = true;
   String? _cacheUser;

  List<PostModel> get posts => _posts;
   Map<int,Map<int,int>> get likes => _likes;
  bool get isLoading => _isLoading;
  String? get cacheUser => _cacheUser;

  Future<void> fetchPosts() async {
    _isLoading = true;
    //notifyListeners();

    try {
      _posts = await getAllPosts();
      for(var post in _posts) {
        _likes[post.postid] = await getLikes(postId: post.postid.toString(), replyId: null);
      }
      _cacheUser = await getUserID();
    } catch (e) {
      _posts = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
