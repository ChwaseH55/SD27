import 'dart:developer';

import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/main.dart';
import 'package:coffee_card/models/post_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/screens/postcreation_screen.dart';
import 'package:coffee_card/widgets/slideRightTransition.dart';
import 'package:coffee_card/widgets/slidedown.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:coffee_card/providers/forum_provider.dart';
import 'package:coffee_card/screens/disscusisonpost_info.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumpostScreen extends StatefulWidget {
  const ForumpostScreen({super.key});

  @override
  State<ForumpostScreen> createState() => _ForumpostScreenState();
}

class _ForumpostScreenState extends State<ForumpostScreen> {
  ForumProvider? forumProvider;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool _isInit = true;
  bool _isLoading = false;
  bool? isRecent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isLoading = true;
      forumProvider = Provider.of<ForumProvider>(context, listen: false);
      forumProvider!.fetchPosts().then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(35.0),
          child: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min, // Ensures minimal spacing
                children: [
                  SizedBox(width: 14),
                  Icon(Icons.arrow_back_ios,
                      color: Colors.black, size: 16), // Reduce size if needed

                  Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            title: const Text('UCF Post',
                style: TextStyle(fontWeight: FontWeight.w900)),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
            actions: [
              IconButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                ),
                onPressed: () async {
                  final res = await Navigator.push(
                    context,
                    SlideDownRoute(
                        page: const PostCreationForm(
                      isUpdate: false,
                      postId: -1,
                      content: '',
                      title: '',
                    )), // your destination
                  );
                  log('$res');
                  if (res == true) {
                    forumProvider!.fetchPosts();
                  }
                },
                icon: const Icon(
                  Icons.add,
                  size: 15,
                ),
              ),
            ],
          )),
      body: Column(
        children: [
          Row(
            children: [
              /// Search Bar
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      suffixIcon: Align(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.filter_list),
                          onSelected: (String result) {
                            setState(() {
                              switch (result) {
                                case 'recent':
                                  isRecent = null;
                                  break;
                                case 'old':
                                  isRecent = false;
                                  break;

                                default:
                              }
                            });
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'recent',
                              child: Text('Newest Posts'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'old',
                              child: Text('Oldest Posts'),
                            ),
                          ],
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black, width: 2.0),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(186, 155, 55, 1), width: 2.0),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      labelText: 'Search Posts',
                      labelStyle: const TextStyle(color: Colors.black),
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Consumer<ForumProvider>(
              builder: (context, forumProvider, child) {
                if (forumProvider.isLoading) {
                  return Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                          color: Colors.black, size: 70));
                }

                final filteredPosts =
                    forumProvider.getFilteredPosts(searchQuery);
                if (isRecent != null && isRecent == false) {
                  filteredPosts
                      .sort((a, b) => a.createddate.compareTo(b.createddate));
                }

                return forumProvider.isLoading
                    ? Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                            color: Colors.black, size: 70))
                    : filteredPosts.isEmpty
                        ? const Center(child: Text('No matching posts found.'))
                        : PostListView(
                            posts: filteredPosts, forumProvider: forumProvider);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PostListView extends StatelessWidget {
  final List<PostModel> posts;
  final ForumProvider forumProvider;

  const PostListView({
    required this.posts,
    required this.forumProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return InkWell(
          onTap: () async {
            final res = await Navigator.push(
                context,
                slideRightRoute(
                    PostsScreenInfo(postId: post.postid.toString())));
            log('$res');
            if (res == true) {
              forumProvider.fetchPosts();
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: PostWidget(
              user: forumProvider.postUsers[post.postid]!,
              replyNum: forumProvider.numReplies[post.postid]!,
              date: post.createddate,
              postName: post.title,
              likeNumber: forumProvider.likes[post.postid]!,
              postId: post.postid.toString(),
              replyId: '',
              userId: forumProvider.cacheUser!,
            ),
          ),
        );
      },
    );
  }
}

class PostWidget extends StatelessWidget {
  final UserModel user;
  final int replyNum;
  final String date;
  final String postName;
  final Map<int, int> likeNumber;
  final String postId;
  final String replyId;
  final String userId;

  const PostWidget({
    super.key,
    required this.user,
    required this.replyNum,
    required this.date,
    required this.postName,
    required this.likeNumber,
    required this.postId,
    required this.replyId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    DateTime time1 = DateTime.parse(date);
    String newDate = timeago.format(time1, locale: 'en_short');
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    bool noPic = user.profilepicture == null;
    
    log('$noPic');



    return TweenAnimationBuilder<Offset>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      tween: Tween(begin: const Offset(1, 0), end: Offset.zero),
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(offset.dx * width, 0),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: SizedBox(
          height: height * 0.15,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                  width: 2.0, color: Colors.black), // black border
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  /// Avatar-like circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(229, 191, 69, 1),
                          Color.fromRGBO(137, 108, 14, 1)
                        ],
                      ),
                    ),
                    child: noPic
                        ? CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.transparent,
                            child: Text(
                              user.username[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ))
                        : CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(user.profilepicture!),
                          ),
                  ),
                  const SizedBox(width: 14),

                  /// Main content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// Post title
                        Text(
                          postName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        /// Subtitle (username and reply count)
                        Row(
                          children: [
                            Text(
                              user.username,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.comment,
                                size: 14, color: Colors.blueAccent),
                            const SizedBox(width: 4),
                            Text(
                              "$replyNum Replies",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  /// Right-side actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LikeButton(
                        isPost: true,
                        likes: likeNumber,
                        id: postId,
                        userId: int.parse(userId),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        newDate.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  final bool isPost;
  final Map<int, int> likes;
  final String id;
  final int userId;

  const LikeButton(
      {super.key,
      required this.isPost,
      required this.likes,
      required this.id,
      required this.userId});

  @override
  Widget build(BuildContext context) {
    return LikeButtonForPost(
        isPost: isPost, likes: likes, id: id, userId: userId);
  }
}

class LikeButtonForPost extends StatefulWidget {
  final bool isPost;
  final Map<int, int> likes;
  final String? id;
  final int? userId;

  const LikeButtonForPost(
      {super.key,
      required this.isPost,
      required this.likes,
      required this.id,
      required this.userId});

  @override
  State<LikeButtonForPost> createState() => _LikeButtonForPost();
}

class _LikeButtonForPost extends State<LikeButtonForPost> with RouteAware {
  late ForumProvider forumProvider;
  bool isLiked = false;
  int counter = 0;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    likeCount = widget.likes.length; // Initialize with the given likeNumber
    if (widget.likes.containsValue(widget.userId)) {
      isLiked = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPushNext() {
    likeApi(); // Call API when navigating away
  }

  @override
  void didPop() {
    likeApi();
  }

  Future<void> likeApi() async {
    if (counter > 0) {
      if (isLiked) {
        if (widget.isPost) {
          await addLike(
              postId: widget.id!,
              replyId: null,
              userId: widget.userId!.toString());
        } else {
          await addLike(
              postId: null,
              replyId: widget.id!,
              userId: widget.userId!.toString());
        }
      } else {
        var likeId = widget.likes.keys.firstWhere(
            (k) => widget.likes[k] == widget.userId,
            orElse: () => -100);

        await deleteLike(likeId: likeId.toString());
      }
      counter = 0;
    }
  }

  void toggleLike() {
    counter++;
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        likeCount += 1;
      } else {
        likeCount -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: toggleLike,
        child: SizedBox(
            width: 60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Row(
                    children: <Widget>[
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                        child: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                          key: ValueKey<bool>(
                              isLiked), // Important for animation to trigger
                          color: isLiked
                              ? const Color.fromRGBO(186, 155, 55, 1)
                              : Colors.black,
                          size: 25,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          likeCount.toString(),
                          style: TextStyle(
                            color: isLiked
                                ? const Color.fromRGBO(186, 155, 55, 1)
                                : Colors.black,
                          ),
                        ),
                      )
                    ],
                  )),
            )));
  }
}
