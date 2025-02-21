import 'package:coffee_card/arguments/postargument.dart';
import 'package:coffee_card/providers/forum_info_provider.dart';
import 'package:coffee_card/providers/forum_reply_provider.dart';
import 'package:coffee_card/widgets/commentchange_widget.dart';
import 'package:coffee_card/widgets/postinfo_widget.dart';
import 'package:coffee_card/widgets/reply_widget.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/models/postwithreplies_model.dart';
import 'package:provider/provider.dart';

class DisscusisonpostInfoScreen extends StatelessWidget {
  const DisscusisonpostInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PostsScreenInfo();
  }
}

class PostsScreenInfo extends StatefulWidget {
  const PostsScreenInfo({super.key});

  static const routeName = '/extractPostId';

  @override
  State<PostsScreenInfo> createState() => _PostsScreenInfoState();
}

class _PostsScreenInfoState extends State<PostsScreenInfo> {
  late PostProvider postProvider;
  late String postId;
  bool isInitialized = false; // Prevents unnecessary re-fetching

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments as PostArguments;
      postId = args.id.toString();
      postProvider = Provider.of<PostProvider>(context, listen: false);

      // Fetch data only once
      postProvider.fetchPostDetails(postId);
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
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
          final userInfo = provider.postUser!;
          final replies = resPost.replies;
          final likesNum = provider.likesCount;

          return Column(
            children: <Widget>[
              PostinfoWidget(
                username: userInfo.username,
                posttitle: resPost.post?.title,
                postContent: resPost.post?.content,
                likeNumber: likesNum,
                postId: resPost.post!.postid.toString(),
                userId: userInfo.id.toString(),
                createDate: resPost.post!.createddate,
              ),
              Expanded(child: ListofReplies(postId: resPost.post!.postid, replies: replies)),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return AddCommentSheet(
                        replyId: '',
                        postId: resPost.post!.postid.toString(),
                        userId: resPost.post!.userid.toString(),
                        content: '',
                        isUpdate: false,
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  ' + Add Comment',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ListofReplies extends StatelessWidget {
  final List<ReplyModel>? replies;
    final int? postId;

  const ListofReplies({super.key, required this.replies, required this.postId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: replies?.length,
      itemBuilder: (context, index) {
        final reply = replies?[index];
        return ChangeNotifierProvider(
          create: (_) => ReplyProvider(reply!.replyid.toString(), reply.userid.toString()),
          child: Consumer<ReplyProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ReplyWidget(
                userName: provider.user?.username ?? "Unknown",
                createDate: reply?.createddate,
                content: reply?.content,
                postId: postId!,
                userId: provider.user!.id,
                replyId: reply?.replyid,
                likeNumber: provider.likesCount,
              );
            },
          ),
        );
      },
    );
  }
}
