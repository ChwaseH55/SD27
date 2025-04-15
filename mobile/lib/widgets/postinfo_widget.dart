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
  final Map<int, int> likes;
  final String? createDate;
  final String? roleNum;

  const PostinfoWidget({
    super.key,
    required this.postId,
    required this.userId,
    required this.likes,
    required this.username,
    required this.posttitle,
    required this.postContent,
    required this.createDate,
    required this.createdBy,
    required this.roleNum,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    String formattedDate =
        DateFormat('MMM d, yyyy').format(DateTime.parse(createDate!));
    bool match = createdBy == userId || roleNum == '5';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// User Info Row
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  // replace with actual image if needed
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(formattedDate,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                if (match)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {},
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "delete",
                        child: InkWell(
                          onTap: () async {
                            await deletePost(postId: postId!);
                            if (context.mounted) {
                              Navigator.pushNamed(context, '/pos');
                            }
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
                  ),
              ],
            ),

            const SizedBox(height: 12),

            /// Post Title
            Text(
              posttitle!,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 8),

            /// Post Content
            Text(
              postContent!,
              style: const TextStyle(fontSize: 15, height: 1.5),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 8),

            /// Like Button
            LikeButton(
              isPost: true,
              likes: likes,
              id: postId!,
              userId: userId!,
            ),
          ],
        ),
      ),
    );
  }
}
