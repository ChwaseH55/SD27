class EventsModel {
  int? eventid;
  String? eventname;
  String? eventdate;
  String? eventlocation;
  String? eventtype;
  bool? requiresregistration;
  int? createdbyuserid;
  String? eventdescription;

  EventsModel(
      {this.eventid,
      this.eventname,
      this.eventdate,
      this.eventlocation,
      this.eventtype,
      this.requiresregistration,
      this.createdbyuserid,
      this.eventdescription});

  factory EventsModel.fromJson(Map<String, dynamic> json) {
    return EventsModel(
      eventid: json['eventid'],
      eventname: json['eventname'],
      eventdate: json['eventdate'],
      eventlocation: json['eventlocation'],
      eventtype: json['eventtype'],
      requiresregistration: json['requiresregistration'],
      createdbyuserid: json['createdbyuserid'],
      eventdescription: json['eventdescription'],
    );
  }
}
