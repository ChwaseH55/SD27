import 'package:coffee_card/models/likes_model.dart';
import 'package:coffee_card/models/post_model.dart';
import 'package:coffee_card/widgets/forumcreation_widget.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/post_discussion_widget.dart';
import 'package:coffee_card/widgets/creationformplus.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/arguments/postargument.dart';
import 'package:coffee_card/screens/disscusisonpost_info.dart';

class ForumpostScreen extends StatelessWidget {
  const ForumpostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UCF Post',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: const PostsScreen(),
      floatingActionButton: const FloatingBtn(),
    );
  }
}

class FloatingBtn extends StatelessWidget {
  const FloatingBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
        alignment: Alignment.bottomRight, child: FormAddWidget());
  }
}

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PostModel>>(
      future: getAllPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts found.'));
        } else {
          final posts = snapshot.data!;
          return Padding(
              padding: const EdgeInsets.only(top: 5),
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return FutureBuilder<List<LikesModel>>(
                    future: getLikesWithPostId(post.postid.toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        final likes = snapshot.data!;
                        return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                PostsScreenInfo.routeName,
                                arguments:  PostArguments(post.postid),
                              );
                            },
                            child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: PostWidget(
                                  postName: post.title,
                                  likeNumber: likes.length,
                                  postId: '12',
                                  replyId: '213',
                                  userId: '34',
                                )));
                      }
                    },
                  );
                },
              ));
        }
      },
    );
  }
}
