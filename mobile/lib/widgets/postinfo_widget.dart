import 'dart:developer';

import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/arguments/postcreateargument.dart';
import 'package:coffee_card/providers/forum_info_provider.dart';
import 'package:coffee_card/providers/forum_provider.dart';
import 'package:coffee_card/screens/postcreation_screen.dart';
import 'package:coffee_card/widgets/likebutton_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostinfoWidget extends StatelessWidget {
  final String? username;
  final String? posttitle;
  final String? postContent;
  final String? postId;
  final int? userId;
  final int? createdBy;
  final Map<int,int> likes;
  final String? createDate;
  final String? roleNum;

  const PostinfoWidget(
      {super.key,
      required this.postId,
      required this.userId,
      required this.likes,
      required this.username,
      required this.posttitle,
      required this.postContent,
      required this.createDate,
      required this.createdBy,
      required this.roleNum});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    String formattedDate =
        DateFormat('MMM d, yyyy').format(DateTime.parse(createDate!));
        bool match = createdBy == userId || roleNum == '5';
    return Padding(
      padding: const EdgeInsets.symmetric(),
      child: SizedBox(
        width: width,
        
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /// **User Info & Menu**
                Row(
                  children: <Widget>[
                    
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        username![0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        username!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    
                    Visibility(
                      visible: match,
                      child: PopupMenuButton<String>(
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
                                if (context.mounted) {
                                  Navigator.pushNamed(context, '/pos');
                                }
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
                                final forumListProvider =
                                    Provider.of<ForumProvider>(context,
                                        listen: false);
                                await Navigator.pushNamed(
                                  context,
                                  PostCreationForm.routeName,
                                  arguments: CreateArgument(true,
                                      int.parse(postId!), posttitle!, postContent!),
                                );
                                if (context.mounted) Navigator.of(context).pop();
                                forumInfoProvider.fetchPostDetails(postId!);
                                forumListProvider.fetchPosts();
                              },
                              child: const Text("Update Post"),
                            ),
                          ),
                        ],
                      )
                    ),
                  ],
                ),
                  const SizedBox(height: 0),
                  /// **Post Title**
                Text(
                  posttitle!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                  const SizedBox(height: 0),
                  /// **Post Content**
                Text(
                  postContent!,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
                  const SizedBox(height: 6),
                  /// **Like Button**
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    LikeButton(
                      isPost: true,
                      likes: likes,
                      id: postId!,
                      userId: userId!,
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      );
    
  }
}

