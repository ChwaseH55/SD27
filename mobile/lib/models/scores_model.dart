class ScoresModel {
  int? scoreid;
  int? eventid;
  int? userid;
  String? approvalstatus;
  int? approvedbyuser;
  String? scoreimage;
  int? score;

  ScoresModel(
      {this.scoreid,
      this.eventid,
      this.userid,
      this.approvalstatus,
      this.approvedbyuser,
      this.scoreimage,
      this.score});

  ScoresModel.fromJson(Map<String, dynamic> json) {
    scoreid = json['scoreid'];
    eventid = json['eventid'];
    userid = json['userid'];
    approvalstatus = json['approvalstatus'];
    approvedbyuser = json['approvedbyuser'];
    scoreimage = json['scoreimage'];
    score = json['score'];
  }
}
