class AnnouncementModel {
  int? announcementid;
  String? title;
  String? content;
  String? createddate;
  int? userid;

  AnnouncementModel(
      {this.announcementid,
      this.title,
      this.content,
      this.createddate,
      this.userid});

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      announcementid: json['announcementid'],
      title: json['title'],
      content: json['content'],
      createddate: json['createddate'],
      userid: json['userid'],
    );
  }
}
