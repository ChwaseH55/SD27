import 'dart:convert';
import 'dart:developer';
import 'package:coffee_card/models/likes_model.dart';
import 'package:http/http.dart';
import 'package:coffee_card/models/post_model.dart';
import 'package:coffee_card/models/postwithreplies_model.dart';

String urlAddress = "http://10.0.2.2:5000/api/forum/";

Future<void> createPost({
  required String title,
  required String content,
  required String? userId,
}) async {
  try {
    final url = Uri.parse('$urlAddress/posts');
    final response = await post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "title": title,
        "content": content,
        "userid": userId,
      }),
    );

    if (response.statusCode == 200) {
      log('Post created successfully: ${response.body}');
    } else {
      log('Error creating post: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<List<PostModel>> getAllPosts() async {
  try {
    final url = Uri.parse('$urlAddress/posts');
    final response = await get(url);

    if (response.statusCode == 200) {
      // Parse JSON response
      final List<dynamic> jsonList = jsonDecode(response.body);
      // Map JSON list to a list of Post objects
      return jsonList.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch posts: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching likes: $e');
  }
}

Future<PostResponse> getPostWithReplies({required String postId}) async {
  try {
    final url = Uri.parse('$urlAddress/posts/$postId');
    final response = await get(url);

    if (response.statusCode == 200) {
      final res = PostResponse.fromJson(json.decode(response.body));
      return res;
    } else {
      throw Exception('Failed to fetch posts and replies: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching post and replies: $e');
  }
}

Future<void> updatePost({
  required String postId,
  required String title,
  required String content,
}) async {
  try {
    final url = Uri.parse('$urlAddress/posts/$postId');
    final response = await put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "title": title,
        "content": content,
      }),
    );

    if (response.statusCode == 200) {
      log('Post updated successfully: ${response.body}');
    } else {
      log('Error updating post: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<void> deletePost({required String postId}) async {
  try {
    final url = Uri.parse('$urlAddress/posts/$postId');
    final response = await delete(url);

    if (response.statusCode == 200) {
      log('Post deleted successfully: ${response.body}');
    } else {
      log('Error deleting post: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<void> addReply({
  required String postId,
  required String content,
  required String userId,
}) async {
  try {
    final url = Uri.parse('$urlAddress/posts/$postId/replies');
    final response = await post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "content": content,
        "userid": userId,
      }),
    );

    if (response.statusCode == 200) {
      log('Reply added successfully: ${response.body}');
    } else {
      log('Error adding reply: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<void> updateReply({
  required String replyId,
  required String content,
}) async {
  try {
    final url = Uri.parse('$urlAddress/replies/$replyId');
    final response = await put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "content": content,
      }),
    );

    if (response.statusCode == 200) {
      log('Reply updated successfully: ${response.body}');
    } else {
      log('Error updating reply: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<void> deleteReply({required String replyId}) async {
  try {
    final url = Uri.parse('$urlAddress/replies/$replyId');
    final response = await delete(url);

    if (response.statusCode == 200) {
      log('Reply deleted successfully: ${response.body}');
    } else {
      log('Error deleting reply: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}

Future<void> addLike({
  required String? postId,
  required String? replyId,
  required String? userId,
}) async {
  try {
    final url = Uri.parse('$urlAddress/likes');
    final response = await post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "postid": postId,
        "replyid": replyId,
        "userid": userId,
      }),
    );

    if (response.statusCode == 200) {
      log('Like added successfully: ${response.body}');
    } else {
      log('Error adding like: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}

// Change to one method
Future<Map<int, int>> getLikes(
    {required String? postId, required String? replyId}) async {
  try {
    Uri url;
    if (postId != null) {
      url = Uri.parse('$urlAddress/likes?postid=$postId');
    } else {
      url = Uri.parse('$urlAddress/likes?replyid=$replyId');
    }

    final response = await get(url);

    if (response.statusCode == 200) {
      log(response.statusCode.toString());
      // Parse JSON response
      final List<dynamic> jsonList = jsonDecode(response.body);
      // Map JSON list to a list of Post objects
      Map<int, int> likesMap = {};
      // Map JSON list to a list of Post objects
      for (var json in jsonList) {
        LikesModel like = LikesModel.fromJson(json);
        likesMap[like.likeid] = like.userid;
      }
      return likesMap;
    } else {
      throw Exception('Failed to fetch posts: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching posts: $e');
  }
}

Future<int> getLikesWithReplyId(String replyId) async {
  try {
    final url = Uri.parse('$urlAddress/likes?postid=$replyId');
    final response = await get(url);

    if (response.statusCode == 200) {
      // Parse JSON response
      final List<dynamic> jsonList = jsonDecode(response.body);
      // Map JSON list to a list of Post objects
      return jsonList.map((json) => LikesModel.fromJson(json)).toList().length;
    } else {
      throw Exception('Failed to fetch posts: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching posts: $e');
  }
}

Future<void> deleteLike({required String likeId}) async {
  try {
    final url = Uri.parse('$urlAddress/likes/$likeId');
    final response = await delete(url);

    if (response.statusCode == 200) {
      log('Like deleted successfully: ${response.body}');
    } else {
      log('Error deleting like: ${response.body}');
    }
  } catch (e) {
    log(e.toString());
  }
}
