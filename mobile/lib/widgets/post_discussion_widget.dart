import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/likebutton_widget.dart';

class PostWidget extends StatelessWidget {
  final String postName;
  final int likeNumber;
  final String postId;
  final String replyId;
  final String userId;

  const PostWidget({
    super.key,
    required this.postName,
    required this.likeNumber,
    required this.postId,
    required this.replyId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
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
              Text(
                postName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // /// **Like Button & Actions Row**
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: <Widget>[
              //     LikeButton(
              //       isPost: true,
              //       likeNumber: likeNumber,
              //       postId: postId,
              //       replyId: replyId,
              //       userId: userId,
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
