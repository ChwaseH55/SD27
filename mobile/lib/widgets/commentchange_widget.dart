import 'dart:developer';

import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/providers/forum_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddCommentSheet extends StatefulWidget {
  final String postId;
  final String userId;
  final bool isUpdate;
  final String content;
  final String replyId;

  const AddCommentSheet(
      {super.key,
      required this.replyId,
      required this.content,
      required this.postId,
      required this.userId,
      required this.isUpdate});

  @override
  State<AddCommentSheet> createState() => _AddCommentSheet();
}

class _AddCommentSheet extends State<AddCommentSheet> {
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with existing content if updating
    commentController = TextEditingController(text: widget.isUpdate ? widget.content : '');
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Add a Comment",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: commentController,  // Always use the initialized controller
            decoration: const InputDecoration(
              hintText: "Enter your comment here",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final forumProvider =
                  Provider.of<PostProvider>(context, listen: false);
              
              if (widget.isUpdate) {
                updateReply(replyId: widget.replyId, content: commentController.text);
              } else {
                if (commentController.text.trim().isEmpty) {
                  return;
                }
                addReply(
                    postId: widget.postId,
                    content: commentController.text,
                    userId: widget.userId);
              }

              // Fetch updated replies
              await forumProvider.fetchPostDetails(widget.postId);

              // Close the bottom sheet
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
