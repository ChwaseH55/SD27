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

class ForumPostForm extends StatefulWidget {
  const ForumPostForm({super.key});

  @override
  State<ForumPostForm> createState() => _ForumPostForm();
}

class FloatingBtn extends StatelessWidget {
  const FloatingBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
        alignment: Alignment.bottomRight, child: FormAddWidget());
  }
}

// This class holds the data related to the Form.
class _ForumPostForm extends State<ForumPostForm> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Username input
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Search',
                ),
              ),
            ),
          ),

          const PostWidget(
            postName: 'Name',
            postNumber: 89,
            likeNumber: 90,
          ),
        ]);
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
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      PostsScreenInfo.routeName,
                      arguments: PostArguments(
                        3,
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(post.title),
                    subtitle: Text(post.content),
                  ));
            },
          );
        }
      },
    );
  }
}
