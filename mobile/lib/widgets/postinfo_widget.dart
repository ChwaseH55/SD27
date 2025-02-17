import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/arguments/postcreateargument.dart';
import 'package:coffee_card/providers/forum_info_provider.dart';
import 'package:coffee_card/providers/forum_provider.dart';
import 'package:coffee_card/screens/postcreation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostinfoWidget extends StatelessWidget {
  final String? username;
  final String? posttitle;
  final String? postContent;
  final String? postId;
  final String? userId;
  final int likeNumber;

  const PostinfoWidget({
    super.key,
    required this.postId,
    required this.userId,
    required this.likeNumber,
    required this.username,
    required this.posttitle,
    required this.postContent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 3, color: Colors.black),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /// **User Info & Menu**
              Row(
                children: <Widget>[
                  const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      username!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      // Handle menu actions
                    },
                    itemBuilder: (context) => [
                       PopupMenuItem(
                        value: "delete",
                        child: InkWell(
                          onTap: () async {
                            final forumProvider = Provider.of<PostProvider>(
                                context,
                                listen: false);
                            await deletePost(postId: postId!);
                            if (context.mounted) Navigator.pushNamed(context, '/pos');
                            await forumProvider.fetchPostDetails(postId!);
                          },
                          child: const Text("Delete Post"),
                        ),
                      ),
                      PopupMenuItem(
                        value: "update",
                        child: InkWell(
                          onTap: () async {
                            final forumInfoProvider = Provider.of<PostProvider>(
                                context,
                                listen: false);
                                final forumListProvider = Provider.of<ForumProvider>(
                                context,
                                listen: false);
                            await Navigator.pushNamed(
                              context,
                              PostCreationForm.routeName,
                              arguments: CreateArgument(true, int.parse(postId!), posttitle!, postContent!),
                            );
                            if (context.mounted) Navigator.of(context).pop(); 
                              forumInfoProvider.fetchPostDetails(postId!);
                              forumListProvider.fetchPosts();
                          },
                          child: const Text("Update Post"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// **Post Title**
              Text(
                posttitle!,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 8),

              /// **Post Content**
              Text(
                postContent!,
                style: const TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.justify,
              ),

              const SizedBox(height: 16),

              /// **Like Button**
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LikeButtonForPost(
                    likeNumber: likeNumber,
                    postId: postId,
                    userId: userId,
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
  final int likeNumber;
  final String postId;
  final String userId;

  const LikeButton(
      {super.key,
      required this.likeNumber,
      required this.postId,
      required this.userId});

  @override
  Widget build(BuildContext context) {
    return LikeButtonForPost(
        likeNumber: likeNumber, postId: postId, userId: userId);
  }
}

class LikeButtonForPost extends StatefulWidget {
  final int likeNumber;
  final String? postId;
  final String? userId;

  const LikeButtonForPost(
      {super.key,
      required this.likeNumber,
      required this.postId,
      required this.userId});

  @override
  State<LikeButtonForPost> createState() => _LikeButtonForPost();
}

class _LikeButtonForPost extends State<LikeButtonForPost> {
  bool isLiked = false;
  late int likeCount; // Mutable variable to store the like count

  @override
  void initState() {
    super.initState();
    likeCount = widget.likeNumber; // Initialize with the given likeNumber
  }

  void toggleLike() {
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
            child: Container(
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
                      Icon(Icons.thumb_up_alt,
                          color: isLiked
                              ? const Color.fromRGBO(186, 155, 55, 1)
                              : Colors.black),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(likeCount.toString()),
                      )
                    ],
                  )),
            )));
  }
}
