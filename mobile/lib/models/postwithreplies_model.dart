class PostModelRows {
  final PostModelWithReply? post;

  const PostModelRows({required this.post});

  factory PostModelRows.fromJson(Map<dynamic, dynamic> json) {
    return PostModelRows(
      post: json['post'] != null
          ? PostModelWithReply.fromJson(json['post'])
          : null, // Map 'post' field to PostModelWithReply
    );
  }
}

class PostModelWithReply {
  final int? postid;
  final int? userid;
  final String? title;
  final String? content;
  final String? createddate;
  final String? updatedate;
  final List<ReplyModel>? replies;

  const PostModelWithReply(
      {required this.postid,
      required this.userid,
      required this.title,
      required this.content,
      required this.createddate,
      required this.updatedate,
      required this.replies});

  factory PostModelWithReply.fromJson(Map<dynamic, dynamic> json) {
    var list = json['replies'] as List? ?? [];
    List<ReplyModel> replyList =
        list.map((i) => ReplyModel.fromJson(i)).toList();

    return PostModelWithReply(
        postid: json['postid'],
        userid: json['userid'],
        title: json['title'],
        content: json['content'],
        createddate: json['createddate'],
        updatedate: json['updatedate'],
        replies: replyList);
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
