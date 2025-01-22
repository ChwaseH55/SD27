import 'package:coffee_card/arguments/postargument.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/models/postwithreplies_model.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/widgets/postinfo_widget.dart';

class DisscusisonpostInfoScreen extends StatelessWidget {
  const DisscusisonpostInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return const PostsScreenInfo();

  }
}

class PostsScreenInfo extends StatelessWidget {
  const PostsScreenInfo({super.key});

  static const routeName = '/extractPostId';

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as PostArguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post Name',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: FutureBuilder<PostModelRows>(
        future: getPostWithReplies(postId: args.id.toString()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No posts found.'));
          } else {
            final resPost = snapshot.data!;
            final resReplies = resPost.post?.replies;
            return   Column(
              children: <Widget>[   PostinfoWidget(username: 'as', posttitle: resPost.post?.title, postContent: resPost.post?.content),
              ]
            );
          }
        },
      )
    );
  }
}
