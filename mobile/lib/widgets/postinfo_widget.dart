import 'package:coffee_card/api_request/forum_request.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/likebutton_widget.dart';


class PostinfoWidget extends StatelessWidget {
  final String? username;
  final String? posttitle;
  final String? postContent;
  final String? postId;
  final String? userId;
  final int? likeNumber;


  const PostinfoWidget({
    super.key,
    required this.postId,
    required this.userId,
    required this.likeNumber,
    required this.username,
    required this.posttitle,
    required this.postContent,
  });


  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height * 0.3,
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Column(
            // Removed const here
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, top: 6),
                child: Column(
                  children: [
                    Row(children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          username!,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: InkWell(
                              onTap: () {
                                //deleteReply(replyId: replyId.toString());// Close the menu manually
                              },
                              child: const Text("Delete Post"),
                            ),
                          ),
                          PopupMenuItem(
                            child: InkWell(
                              onTap: () {
                                //deleteReply(replyId: replyId.toString());// Close the menu manually
                              },
                              child: const Text("Update Post"),
                            ),
                          ),
                        ],
                      )
                    ]),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        posttitle!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(postContent!,
                          style: const TextStyle(
                            fontSize: 28,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 35),
                      child:  Align(
                        alignment: Alignment.centerLeft,
                        child:  LikeButtonForPost(likeNumber: likeNumber, postId: postId, userId: userId,)
                      )
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class LikeButton extends StatelessWidget {
  final int likeNumber;
  final String postId;
  final String userId;


  const LikeButton(
      {super.key,
      required this.likeNumber,
      required this.postId,
      required this.userId});


  @override
  Widget build(BuildContext context) {
    return LikeButtonForPost(likeNumber: likeNumber, postId: postId, userId: userId);
  }
}


class LikeButtonForPost extends StatefulWidget {
  final int? likeNumber;
  final String? postId;
  final String? userId;


  const LikeButtonForPost({super.key, required this.likeNumber, required this.postId,  required this.userId});


  @override
  State<LikeButtonForPost> createState() => _LikeButtonForPost();
}


class _LikeButtonForPost extends State<LikeButtonForPost> {
  bool isLiked = false;
  @override
  Widget build(BuildContext context) {
   
    return GestureDetector(
        onTap: () {
          //addLike(postId: widget.postId, replyId: replyId, userId: userId);
          setState(() {
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








