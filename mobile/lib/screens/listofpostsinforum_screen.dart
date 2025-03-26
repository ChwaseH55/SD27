import 'dart:developer';

import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/arguments/postcreateargument.dart';
import 'package:coffee_card/main.dart';
import 'package:coffee_card/screens/postcreation_screen.dart';
import 'package:coffee_card/widgets/likebutton_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:coffee_card/providers/forum_provider.dart';
import 'package:coffee_card/screens/disscusisonpost_info.dart';
import 'package:coffee_card/arguments/postargument.dart';
import 'package:coffee_card/widgets/post_discussion_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(35.0),
        child: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min, // Ensures minimal spacing
              children: [
                SizedBox(width: 14),
                Icon(Icons.arrow_back_ios,
                    color: Colors.black, size: 16), // Reduce size if needed
          
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ),
          title: const Text('UCF Post',
              style: TextStyle(fontWeight: FontWeight.w900)),
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
                  arguments: CreateArgument(false, -1, '', ''),
                );
                // Force refresh after returning from create post screen
                forumProvider.fetchPosts();
              },
              child: const Text('+ Create Post'),
            ),
          ],
        )
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 13.0, left: 8.0, right: 8.0, bottom: 8.0),
            child: TextField(
              controller: searchController,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                
                fillColor: Colors.white,
                filled: true,
                
                focusedBorder: OutlineInputBorder(
                  
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(186, 155, 55, 1), width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                labelText: 'Search Posts',
                labelStyle: const TextStyle(color: Colors.black),
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
                            onTap: () async {
                              Navigator.pushNamed(
                                context,
                                PostsScreenInfo.routeName,
                                arguments: PostArguments(post.postid),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: PostWidget(
                                date: post.createddate,
                                postName: post.title,
                                likeNumber: forumProvider.likes[post.postid]!,
                                postId: post.postid.toString(),
                                replyId: '',
                                userId: forumProvider.cacheUser!,
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

class PostWidget extends StatelessWidget {
  final String date;
  final String postName;
  final Map<int, int> likeNumber;
  final String postId;
  final String replyId;
  final String userId;

  const PostWidget({
    super.key,
    required this.date,
    required this.postName,
    required this.likeNumber,
    required this.postId,
    required this.replyId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    DateTime time1 = DateTime.parse(date);
    String newDate = timeago.format(time1, locale: 'en_short');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 3.0, color: Colors.black),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /// **Post Title**
              Row(children: <Widget>[
                Text(
                  postName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  newDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ]),
              const SizedBox(height: 12),

              // /// **Like Button & Actions Row**
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  LikeButton(
                    isPost: true,
                    likes: likeNumber,
                    id: postId,
                    userId: int.parse(userId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  final bool isPost;
  final Map<int, int> likes;
  final String id;
  final int userId;

  const LikeButton(
      {super.key,
      required this.isPost,
      required this.likes,
      required this.id,
      required this.userId});

  @override
  Widget build(BuildContext context) {
    return LikeButtonForPost(
        isPost: isPost, likes: likes, id: id, userId: userId);
  }
}

class LikeButtonForPost extends StatefulWidget {
  final bool isPost;
  final Map<int, int> likes;
  final String? id;
  final int? userId;

  const LikeButtonForPost(
      {super.key,
      required this.isPost,
      required this.likes,
      required this.id,
      required this.userId});

  @override
  State<LikeButtonForPost> createState() => _LikeButtonForPost();
}

class _LikeButtonForPost extends State<LikeButtonForPost> with RouteAware {
  late ForumProvider forumProvider;
  bool isLiked = false;
  int counter = 0;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes.length; // Initialize with the given likeNumber
    if (widget.likes.containsValue(widget.userId)) {
      isLiked = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPushNext() {
    likeApi(); // Call API when navigating away
  }

  @override
  void didPop() {
    likeApi();
  }

  Future<void> likeApi() async {
    if (counter > 0) {
      if (isLiked) {
        if (widget.isPost) {
          await addLike(
              postId: widget.id!,
              replyId: null,
              userId: widget.userId!.toString());
        } else {
          await addLike(
              postId: null,
              replyId: widget.id!,
              userId: widget.userId!.toString());
        }
      } else {
        var likeId = widget.likes.keys.firstWhere(
            (k) => widget.likes[k] == widget.userId,
            orElse: () => -100);

        await deleteLike(likeId: likeId.toString());
      }
      counter = 0;
    }
  }

  void toggleLike() {
    counter++;
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        likeCount += 1;
      } else {
        likeCount -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: toggleLike,
        child: SizedBox(
            width: 60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                    color: isLiked
                        ? const Color.fromRGBO(186, 155, 55, 1)
                        : Colors.black,
                    width: 2),
                borderRadius:
                    const BorderRadius.all(Radius.elliptical(90, 100)),
              ),
              child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Row(
                    children: <Widget>[
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                        child: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                          key: ValueKey<bool>(
                              isLiked), // Important for animation to trigger
                          color: isLiked ? const Color.fromRGBO(186, 155, 55, 1) : Colors.black,
                          size: 25,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(likeCount.toString(), style: TextStyle(color: isLiked
                        ? const Color.fromRGBO(186, 155, 55, 1)
                        : Colors.black,),),
                      )
                    ],
                  )),
            )));
  }
}
