import 'dart:developer';

import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/providers/forum_info_provider.dart';
import 'package:coffee_card/providers/forum_reply_provider.dart';
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
    commentController =
        TextEditingController(text: widget.isUpdate ? widget.content : '');
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return AnimatedPadding(
    duration: const Duration(milliseconds: 550),
    curve: Curves.easeOut,
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom * 0.0, // 👈 this handles keyboard space
    ),
    child: SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                cursorColor: const Color.fromRGBO(186, 155, 55, 1),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(186, 155, 55, 1),
                      width: 2,
                    ),
                  ),
                  hintText: 'Add a Comment',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                final replyProvider =
                    Provider.of<PostProvider>(context, listen: false);

                if (widget.isUpdate) {
                  await replyProvider.editReplyAndRefresh(
                    widget.replyId,
                    commentController.text,
                    widget.postId,
                  );
                } else {
                  if (commentController.text.trim().isEmpty) return;
                  await replyProvider.addReplyAndRefresh(
                    widget.postId,
                    commentController.text,
                    widget.userId,
                  );
                }

                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    ),
  );
}



}
