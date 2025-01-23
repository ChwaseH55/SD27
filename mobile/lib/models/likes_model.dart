class LikesModel {
  final int likeid;
  final int userid;
  

  const LikesModel({
    required this.likeid,
    required this.userid,
  });

  factory LikesModel.fromJson(Map<dynamic, dynamic> json) {
    return LikesModel(
      likeid: json['likeid'],
      userid: json['userid'],
    );
  }
}


