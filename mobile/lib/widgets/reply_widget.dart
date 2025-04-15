import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/providers/forum_info_provider.dart';
import 'package:coffee_card/widgets/commentchange_widget.dart';
import 'package:coffee_card/widgets/likebutton_widget.dart';

class ReplyWidget extends StatelessWidget {
  final String userName;
  final String? createDate;
  final String? content;
  final int? replyId;
  final int postId;
  final int createdBy;
  final int userId;
  final Map<int, int> likes;
  final String? roleNum;

  const ReplyWidget({
    super.key,
    required this.userName,
    required this.createDate,
    required this.content,
    required this.replyId,
    required this.postId,
    required this.userId,
    required this.createdBy,
    required this.likes,
    required this.roleNum,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('MMM d, yyyy').format(DateTime.parse(createDate!));
    bool match = createdBy == userId || roleNum == '5';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FBFE),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// User Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF3C3C3C),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (match)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (value) {},
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "delete",
                        child: InkWell(
                          onTap: () async {
                            Navigator.of(context).pop();
                            final forumProvider = Provider.of<PostProvider>(
                                context,
                                listen: false);
                            await forumProvider.deleteReplyAndRefresh(
                                replyId.toString(), postId.toString());
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Reply deleted successfully")),
                              );
                            }
                          },
                          child: const Text("Delete Reply"),
                        ),
                      ),
                      PopupMenuItem(
                        value: "update",
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                return AddCommentSheet(
                                  replyId: replyId.toString(),
                                  postId: postId.toString(),
                                  userId: '',
                                  content: content!,
                                  isUpdate: true,
                                );
                              },
                            );
                          },
                          child: const Text("Update Reply"),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 10),

            /// Reply Content
            Text(
              content!,
              style: const TextStyle(fontSize: 14, height: 1.4),
              textAlign: TextAlign.left,
            ),

            const SizedBox(height: 10),

            /// Like Row
            Row(
              children: [
                LikeButton(
                  isPost: false,
                  likes: likes,
                  id: replyId.toString(),
                  userId: userId,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
