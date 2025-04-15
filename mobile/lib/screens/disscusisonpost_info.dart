import 'package:coffee_card/arguments/postargument.dart';
import 'package:coffee_card/providers/forum_info_provider.dart';
import 'package:coffee_card/providers/forum_reply_provider.dart';
import 'package:coffee_card/widgets/appBar_widget.dart';
import 'package:coffee_card/widgets/commentchange_widget.dart';
import 'package:coffee_card/widgets/postinfo_widget.dart';
import 'package:coffee_card/widgets/reply_widget.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/models/postwithreplies_model.dart';
import 'package:provider/provider.dart';


class PostsScreenInfo extends StatefulWidget {
   final String? postId;
  const PostsScreenInfo({super.key, required this.postId});



  @override
  State<PostsScreenInfo> createState() => _PostsScreenInfoState();
}

class _PostsScreenInfoState extends State<PostsScreenInfo> {
  late PostProvider postProvider;
  late String postId;
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      postId = widget.postId!;
      postProvider = Provider.of<PostProvider>(context, listen: false);
      final replyProvider = Provider.of<ReplyProvider>(context, listen: false);

      postProvider.fetchPostDetails(postId).then((_) {
        final replies = postProvider.postDetails?.replies ?? [];
        replyProvider.fetchReplyDetailsList(replies);
      });

      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return 
       PopScope(
        
  canPop: true,
  onPopInvokedWithResult: (didPop, bool? value) async {
    if (!didPop) {
      // optional logic here
      Navigator.pop(context, true); // ✅ this is what you're missing
    }
  },

         child: Scaffold(
          appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading:  BackButton(
                  color: Colors.black,
                  onPressed: () {
                    Navigator.pop(context,true);
                  },
                )
             ,
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.account_circle_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/pro');
              },
            )
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(186, 155, 55, 1),
                  Color.fromARGB(255, 240, 219, 130),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
             ),
          body: Consumer<PostProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
                if (provider.postDetails == null || provider.postUser == null) {
                return const Center(child: Text('No posts found.'));
              }
                final resPost = provider.postDetails!;
              final postUser = provider.postUser!;
              final cachedUser = provider.cacheUser!;
              final replies = resPost.replies;
              final likesNum = provider.likes;
              final roleNum = provider.roleid;
                return Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0)),
                  child: Column(
                    children: <Widget>[
                      PostinfoWidget(
                        roleNum: roleNum,
                        username: postUser.username,
                        posttitle: resPost.post?.title,
                        postContent: resPost.post?.content,
                        likes: likesNum,
                        postId: resPost.post!.postid.toString(),
                        userId: cachedUser.id,
                        createdBy: postUser.id,
                        createDate: resPost.post!.createddate,
                      ),
                      Expanded(
                          child: ListofReplies(
                              postId: resPost.post!.postid, replies: replies)),
                      SizedBox(
                          width: width,
                          height: height * 0.06,
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 3,
                                    blurRadius: 8,
                                    offset: const Offset(0, -3),
                                  ),
                                ],
                              ),
                              child: Center(
                                  child: SizedBox(
                                      width: width * 0.4,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(20)),
                                            ),
                                            builder: (context) {
                                              return AddCommentSheet(
                                                replyId: '',
                                                postId:
                                                    resPost.post!.postid.toString(),
                                                userId: cachedUser.id.toString(),
                                                content: '',
                                                isUpdate: false,
                                              );
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color.fromRGBO(186, 155, 55, 1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          ' + Add Comment',
                                          style: TextStyle(
                                              fontSize: 13, color: Colors.black),
                                        ),
                                      )))))
                    ],
                  ));
            },
          ),
         )
       );
  }
}

class ListofReplies extends StatelessWidget {
  final List<ReplyModel>? replies;
  final int? postId;

  const ListofReplies({super.key, required this.replies, required this.postId});

  @override
  Widget build(BuildContext context) {
    final replyProvider = Provider.of<ReplyProvider>(context);

    if (replyProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final userId = replyProvider.userId;
    final roleId = replyProvider.roleId;

    return ListView.builder(
      itemCount: replies?.length ?? 0,
      itemBuilder: (context, index) {
        final reply = replies![index];
        final user = replyProvider.users[reply.replyid!];
        final likeMap = replyProvider.likes[reply.replyid!] ?? {};

        return ReplyWidget(
          userName: user?.username ?? 'Unknown',
          createDate: reply.createddate,
          content: reply.content,
          postId: postId!,
          userId: int.parse(userId ?? '0'),
          replyId: reply.replyid,
          likes: likeMap,
          createdBy: reply.userid!,
          roleNum: roleId,
        );
      },
    );
  }
}
