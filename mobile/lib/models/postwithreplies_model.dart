class PostResponse {
  final PostModelReplies? post;
  final List<ReplyModel>? replies;

  const PostResponse({
    required this.post,
    required this.replies,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    var repliesList = json['replies'] as List? ?? [];
    List<ReplyModel> replyItems = repliesList.map((i) => ReplyModel.fromJson(i)).toList();

    return PostResponse(
      post: PostModelReplies.fromJson(json['post']),
      replies: replyItems,
    );
  }

}

class PostModelReplies {
  final int? postid;
  final int? userid;
  final String? title;
  final String? content;
  final String? createddate;
  final String? updatedate;

  const PostModelReplies({
    required this.postid,
    required this.userid,
    required this.title,
    required this.content,
    required this.createddate,
    required this.updatedate,
  });

  factory PostModelReplies.fromJson(Map<String, dynamic> json) {
    return PostModelReplies(
      postid: json['postid'],
      userid: json['userid'],
      title: json['title'],
      content: json['content'],
      createddate: json['createddate'],
      updatedate: json['updatedate'],
    );
  }
}

class ReplyModel {
  final int? replyid;
  final int? postid;
  final int? parentreplyid;
  final int? userid;
  final String? content;
  final String? createddate;
  final String? updatedate;

  const ReplyModel({
    required this.replyid,
    required this.postid,
    required this.parentreplyid,
    required this.userid,
    required this.content,
    required this.createddate,
    required this.updatedate,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      replyid: json['replyid'],
      postid: json['postid'],
      parentreplyid: json['parentreplyid'],
      userid: json['userid'],
      content: json['content'],
      createddate: json['createddate'],
      updatedate: json['updatedate'],
    );
  }
}
