import 'dart:developer';

import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/user_model.dart';

class Chat {
  final String id;
  final String name;
  final String type;
  final Map<String, bool> participants;
  final String? lastMessage;
  final int? lastMessageDate;
  final String createdBy;
  final int createdAt;

  Chat(
      {required this.id,
      required this.name,
      required this.type,
      required this.participants,
      required this.createdBy,
      required this.createdAt,
      this.lastMessage,
      this.lastMessageDate});

  factory Chat.fromJson(String id, Map<dynamic, dynamic> json) {
  try {
    final lastMessageData = json['lastMessage'] as Map<dynamic, dynamic>?; // Safely cast to a Map
    
    return Chat(
      id: id,
      createdAt: json['createdAt'],
      name: json['name'] ?? 'Chat',
      createdBy: json['createdBy'],
      type: json['type'] ?? 'direct',
      participants: Map<String, bool>.from(json['participants'] ?? {}),
      lastMessage: lastMessageData?['text'] ?? '',  // Check if lastMessageData is null before accessing
      lastMessageDate: lastMessageData?['timestamp'] ?? 0, // Prevent null exception
//sdsds
    );
  } catch (e) {
    log(e.toString());
    throw Exception('Error: $e');
  }
}


}

