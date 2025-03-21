import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/providers/forum_info_provider.dart';
import 'package:coffee_card/widgets/commentchange_widget.dart';
import 'package:coffee_card/widgets/likebutton_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  const ReplyWidget(
      {super.key,
      required this.userName,
      required this.createDate,
      required this.content,
      required this.replyId,
      required this.postId,
      required this.userId,
      required this.createdBy,
      required this.likes,
      required this.roleNum});

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('MMM d, yyyy').format(DateTime.parse(createDate!));
    bool match = createdBy == userId || roleNum == '5';
    return Column(children: <Widget>[
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /// **User & Date Row**
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        userName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.black,
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
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
                                  Navigator.of(context)
                                      .pop(); // Close the popup before action
                                  final forumProvider =
                                      Provider.of<PostProvider>(context,
                                          listen: false);
                                  await forumProvider.deleteReplyAndRefresh(
                                      replyId.toString(), postId.toString());
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Reply deleted successfully")),
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
                        )),
                  ],
                ),
                const SizedBox(height: 2),

                /// **Reply Content**
                Text(
                  content!,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                  textAlign: TextAlign.justify,
                  softWrap: true, // Ensures text wraps properly
                  maxLines: null, // Allows unlimited lines
                ),
                const SizedBox(height: 2),

                /// **Like Button**
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
          )),
    ]);
  }
}
