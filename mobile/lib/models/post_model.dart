import 'package:coffee_card/api_request/user_request.dart';

class PostModel {
  final int postid;
  final int userid;
  final String title;
  final String content;
  final String createddate;
  final String updatedate;

  const PostModel({
    required this.postid,
    required this.userid,
    required this.title,
    required this.content,
    required this.createddate,
    required this.updatedate,
  });

  factory PostModel.fromJson(Map<dynamic, dynamic> json) {
    return PostModel(
      postid: json['postid'],
      userid: json['userid'],
      title: json['title'],
      content: json['content'],
      createddate: json['createddate'],
      updatedate: json['updatedate'],
    );
  }
}
