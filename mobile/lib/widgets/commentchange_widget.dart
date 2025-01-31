import 'package:coffee_card/api_request/forum_request.dart';
import 'package:flutter/material.dart';

class AddCommentSheet extends StatefulWidget {
  final String postId;
  final String userId;
  final bool isUpdate;

  const AddCommentSheet(
      {super.key,
      required this.postId,
      required this.userId,
      required this.isUpdate});

  @override
  State<AddCommentSheet> createState() => _AddCommentSheet();
}

class _AddCommentSheet extends State<AddCommentSheet> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
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
        bottom: MediaQuery.of(context).viewInsets.bottom +
            16, // Adjust for keyboard
      ),
      child: Column(
        mainAxisSize: MainAxisSize
            .min, // Ensures the sheet doesn't take up the full screen
        children: [
          const Text(
            "Add a Comment",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: widget.isUpdate
                ? TextEditingController(text: 'test')
                : commentController,
            decoration: const InputDecoration(
              hintText: "Enter your comment here",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (widget.isUpdate) {
                //updateReply(replyId: widget.replyId, content: commentController.text);
              } else {
                // addReply(
                //     postId: widget.postId,
                //     content: commentController.text,
                //     userId: widget.userId);
              }

              // Handle comment submission
              Navigator.pop(context); // Close the bottom sheet
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
