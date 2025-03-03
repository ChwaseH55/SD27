import 'package:flutter/material.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/postwithreplies_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/models/likes_model.dart';

class PostProvider extends ChangeNotifier {
  PostResponse? _postDetails;
  UserModel? _postUser;
  int _likesCount = 0;
  bool _isLoading = true;

  PostResponse? get postDetails => _postDetails;
  UserModel? get postUser => _postUser;
  int get likesCount => _likesCount;
  bool get isLoading => _isLoading;

  Future<void> fetchPostDetails(String postId) async {
    _isLoading = true;

    try {
      _postDetails = await getPostWithReplies(postId: postId);
      if (_postDetails?.post != null) {
        _postUser =
            await getUser(userId: _postDetails!.post!.userid.toString());
        _likesCount = await getLikesWithPostId(postId: postId);
      
      }
    } catch (e) {
      _postDetails = null;
      _postUser = null;
      _likesCount = 0;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteReplyAndRefresh(String replyId, String postId) async {
    await deleteReply(replyId: replyId) ;// Ensure delete completes before fetching
    await fetchPostDetails(postId);  // Refresh the post data
    notifyListeners();  // Force UI update
  }

}
