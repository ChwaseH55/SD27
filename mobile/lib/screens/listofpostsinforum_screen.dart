import 'package:coffee_card/arguments/postcreateargument.dart';
import 'package:coffee_card/screens/postcreation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_card/providers/forum_provider.dart';
import 'package:coffee_card/screens/disscusisonpost_info.dart';
import 'package:coffee_card/arguments/postargument.dart';
import 'package:coffee_card/widgets/post_discussion_widget.dart';

class ForumpostScreen extends StatefulWidget {
  const ForumpostScreen({super.key});

  @override
  State<ForumpostScreen> createState() => _ForumpostScreenState();
}

class _ForumpostScreenState extends State<ForumpostScreen> {
  late ForumProvider forumProvider;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    forumProvider = Provider.of<ForumProvider>(context, listen: false);
    forumProvider.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UCF Post', style: TextStyle(fontWeight: FontWeight.w900)),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 13.0,left: 8.0,right: 8.0,bottom: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
          
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(186, 155, 55, 1), width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                labelText: 'Search Posts',
                labelStyle:
                    const TextStyle(color: Colors.black),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<ForumProvider>(
              builder: (context, forumProvider, child) {
                if (forumProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredPosts = forumProvider.posts.where((post) {
                  return post.title.toLowerCase().contains(searchQuery);
                }).toList();

                if (filteredPosts.isEmpty) {
                  return const Center(child: Text('No matching posts found.'));
                }

                return ListView.builder(
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
                    return GestureDetector(
                      onTap: () {
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
                          likeNumber: 1111, // Consider fetching like count dynamically
                          postId: post.postid.toString(),
                          replyId: '',
                          userId: '34',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
