import 'package:flutter/material.dart';

class LikebuttonWidget extends StatelessWidget {
  final int likeNumber;
  final String postId;
  final String replyId;
  final String userId;

  const LikebuttonWidget(
      {super.key, 
      required this.likeNumber, 
      required this.postId, 
      required this.replyId, 
      required this.userId});

  @override
  Widget build(BuildContext context) {
    return LikeButton(likeNumber: likeNumber, postId: postId, replyId: replyId, userId: userId);
  }
}

class LikeButton extends StatefulWidget {
  final int likeNumber;
  final String postId;
  final String replyId;
  final String userId;

  const LikeButton({super.key, required this.likeNumber, required this.postId, required this.replyId, required this.userId});

  @override
  State<LikeButton> createState() => _LikeButton();
}

class _LikeButton extends State<LikeButton> {
  bool isLiked = false;
  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
        onTap: () {
          setState(() {
            // Toggle light when tapped.
            isLiked = !isLiked;
          });
        },
        
        child: SizedBox(
            width: 60,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: isLiked ? const Color.fromRGBO(186, 155, 55, 1) : Colors.black, width: 2),
                borderRadius:
                    const BorderRadius.all(Radius.elliptical(90, 100)),
              ),
              child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.thumb_up_alt, color: isLiked ? const Color.fromRGBO(186, 155, 55, 1) : Colors.black),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(widget.likeNumber.toString()
                      ),)
                    ],
                  )),
            )));
  }
}


