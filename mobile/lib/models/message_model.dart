class Message {
  final String id;
  final String? text;
  final String? imageUrl;
  final String senderId;
  final String senderName;
  final int timestamp;
  final bool? edited;
  final int? editedAt;


  Message({
    required this.id,
    this.text,
    this.imageUrl,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
     this.edited,
     this.editedAt,
  });

  factory Message.fromJson(String id, Map<dynamic, dynamic> json) {
    return Message(
      id: id,
      text: json['text'],
      imageUrl: json['image'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      timestamp: json['timestamp'],
      edited: json['edited'],
      editedAt: json['editedAt'],
    );
  }
}