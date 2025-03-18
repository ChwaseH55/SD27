import 'dart:developer';

import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/providers/forum_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class _LikeButtonForPost extends State<LikeButtonForPost> {
   late ForumProvider forumProvider;
  bool isLiked = false;
  int counter = 0;
  late int likeCount; // Mutable variable to store the like count

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
 forumProvider = Provider.of<ForumProvider>(context, listen: false);
}

  @override
  void dispose() {
    likeApi();
    super.dispose();
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
      await forumProvider.fetchPosts();
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
                        child: Text(likeCount.toString()),
                      )
                    ],
                  )),
            )));
  }
}
