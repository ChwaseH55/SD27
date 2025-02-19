class EventCreateArgument {
  final bool isUpdate;
  final int eventId;
  final String title;
  final String content;
  final String location;
  final String type;
  final bool registration;
  final String date;
  EventCreateArgument(this.isUpdate, this.eventId, this.title, this.content,
      this.location, this.type, this.registration, this.date);
}
