import 'package:coffee_card/widgets/commentchange_widget.dart';
import 'package:coffee_card/widgets/likebutton_widget.dart';
import 'package:flutter/material.dart';

class ReplyWidget extends StatelessWidget {
  final String userName;
  final String? createDate;
  final String? content;
  final int replyId;
  final int postId;
  final int userId;
  final int likeNumber;

  const ReplyWidget(
      {super.key,
      required this.userName,
      required this.createDate,
      required this.content,
      required this. replyId,
      required this.postId,
      required this.userId,
      required this.likeNumber});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        // onTap: () {
        //   Navigator.pushNamed(context, '/anncDetail');
        // },
        child: Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 8, bottom: 10, top: 5),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.black),
                    )),
                Text(createDate!),
                const Spacer(),
                PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: InkWell(
                        onTap: () {
                          //deleteReply(replyId: replyId.toString());// Close the menu manually
                        },
                        child: const Text("Delete Reply"),
                      ),
                    ),
                    PopupMenuItem(
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20))),
                          builder: (context) {
                            return  AddCommentSheet(postId: postId.toString(), userId: userId.toString(), isUpdate: true,);
                          });
                          //deleteReply(replyId: replyId.toString());// Close the menu manually
                        },
                        child: const Text("Update Reply"),
                      ),
                    ),
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: <Widget>[Text(content!)],
              ),
            ),
            Row(children: <Widget>[
              LikeButton(
                likeNumber: likeNumber,
                postId: postId.toString(),
                replyId: replyId.toString(),
                userId: userId.toString(),
              )
            ]),
          ],
        ),
      ),
    ));
  }
}


