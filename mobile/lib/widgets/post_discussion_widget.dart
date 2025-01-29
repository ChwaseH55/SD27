import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/likebutton_widget.dart';

class PostWidget extends StatelessWidget {
  final String postName;
  final int likeNumber;
  final String postId;
  final String replyId;
  final String userId;

  const PostWidget(
      {super.key, required this.postName, required this.likeNumber, required this.postId, required this.replyId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 8, bottom: 10),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: Row(
                    children: <Widget>[
                      Text(
                        postName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(children: <Widget>[
                       LikeButton(likeNumber: likeNumber, postId: postId, replyId: replyId, userId: userId,),
                          
                    ])),
              ],
            ),
          ),
        ));
  }
}

