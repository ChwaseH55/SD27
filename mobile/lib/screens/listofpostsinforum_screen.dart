import 'package:coffee_card/arguments/postcreateargument.dart';
import 'package:coffee_card/providers/forum_provider.dart';
import 'package:coffee_card/screens/postcreation_screen.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/post_discussion_widget.dart';
import 'package:coffee_card/widgets/creationformplus.dart';
import 'package:coffee_card/arguments/postargument.dart';
import 'package:coffee_card/screens/disscusisonpost_info.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

class ForumpostScreen extends StatefulWidget {
  const ForumpostScreen({super.key});

  @override
  State<ForumpostScreen> createState() => _ForumpostScreenState();
}

class _ForumpostScreenState extends State<ForumpostScreen> {
  late ForumProvider forumProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Fetch latest posts when screen is revisited
    forumProvider = Provider.of<ForumProvider>(context, listen: false);
    forumProvider.fetchPosts();
  }

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
        actions: [
          TextButton(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
            ),
            onPressed: () async {
              await Navigator.pushNamed(
                        context,
                        PostCreationForm.routeName,
                        arguments: CreateArgument(false, -1, '',''),
                      );
              // Force refresh after returning from create post screen
              forumProvider.fetchPosts();
            },
            child: const Text('+ Create Post'),
          ),
        ],
      ),
      body: const PostsScreen(),
      
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
    return Consumer<ForumProvider>(
      builder: (context, forumProvider, child) {
        if (forumProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (forumProvider.posts.isEmpty) {
          return const Center(child: Text('No posts found.'));
        }

        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: ListView.builder(
            itemCount: forumProvider.posts.length,
            itemBuilder: (context, index) {
              final post = forumProvider.posts[index];

              return FutureBuilder<int>(
                future: forumProvider.getLikesCount(post.postid.toString()),
                builder: (context, snapshot) {
                  final likeCount = snapshot.data ?? 0;
                  return GestureDetector(
                    onTap: () {
                      log('ent5ered');
                      Navigator.pushNamed(
                        context,
                        PostsScreenInfo.routeName,
                        arguments: PostArguments(post.postid),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: PostWidget(
                        postName: post.title,
                        likeNumber: likeCount,
                        postId: post.postid.toString(),
                        replyId: '213',
                        userId: '34',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

