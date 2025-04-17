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
    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, bool? value) async {
          if (!didPop) {
            // optional logic here
            Navigator.pop(context, true); // ✅ this is what you're missing
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: const CustomAppBar(title: '', showBackButton: true,),
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

              return Stack(
                children: [
                  Column(
                    children: <Widget>[
                      PostinfoWidget(
                        picture: postUser.profilepicture,
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
                          postId: resPost.post!.postid,
                          replies: replies,
                        ),
                      ),
                       // Add space for the comment field
                    ],
                  ),
                  // Positioned input field above keyboard
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 50),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: SafeArea(
                        top: false,
                        child: AddCommentSheet(
                          replyId: '',
                          postId: resPost.post!.postid.toString(),
                          userId: cachedUser.id.toString(),
                          content: '',
                          isUpdate: false,
                        )
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ));
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
          picture: user!.profilepicture ,
          userName: user.username ,
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
