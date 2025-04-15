import 'dart:developer';

import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/models/post_model.dart';

class ForumProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  final Map<int, int> _numReplies = {};
  final Map<int, UserModel> _postUsers = {};
  final Map<int, Map<int, int>> _likes = {};
  bool _isLoading = true;
  String? _cacheUser;

  List<PostModel> get posts => _posts;
  Map<int, int> get numReplies => _numReplies;
  Map<int, UserModel> get postUsers => _postUsers;
  Map<int, Map<int, int>> get likes => _likes;
  bool get isLoading => _isLoading;
  String? get cacheUser => _cacheUser;

  Future<void> fetchPosts() async {
    _isLoading = true;
    // Removed early notifyListeners()

    try {
      _posts = await getAllPosts();
      _cacheUser = await getUserID();
      Set<int> fetchedUserIds = {};

      await Future.wait(_posts.map((post) async {
        final likesFuture =
            getLikes(postId: post.postid.toString(), replyId: null);
        final repliesFuture =
            getPostWithReplies(postId: post.postid.toString());
        final userFuture = (!_postUsers.containsKey(post.userid) &&
                !fetchedUserIds.contains(post.userid))
            ? getSingleUser(userId: post.userid.toString())
            : Future.value(null);

        final results =
            await Future.wait([likesFuture, repliesFuture, userFuture]);

        _likes[post.postid] = results[0] as Map<int, int>;
        _numReplies[post.postid] = (results[1] as dynamic).replies?.length ?? 0;

        if (results[2] != null) {
          if (results[2] is UserModel) {
            final user = results[2] as UserModel;
            
            _postUsers[post.postid] = user;
          } else {
            log("User casting failed: ${results[2].runtimeType}");
          }
          fetchedUserIds.add(post.userid);
        } else if (_postUsers.containsKey(post.userid)) {
          _postUsers[post.postid] = _postUsers[post.userid]!;
        }
      }));
    } catch (e) {
      log(e.toString());
      _posts = [];
    }

    _isLoading = false;
    notifyListeners(); // ✅ Only notify once, after everything is done
  }

  Future<void> addLikeAndRefresh(String id, String user) async {
    await addLike(
        postId: id,
        replyId: null,
        userId: user); // Ensure delete completes before fetching
    await getAllPosts();
    notifyListeners(); // Force UI update
  }

  Future<void> removeLikeAndRefresh(String like) async {
    await deleteLike(likeId: like); // Ensure delete completes before fetching
    await getAllPosts();
    notifyListeners(); // Force UI update
  }

  List<PostModel> getFilteredPosts(String query) {
    return _posts
        .where((post) => post.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
