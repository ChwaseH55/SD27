import 'package:coffee_card/screens/chat_widget.dart';
import 'package:flutter/material.dart';

class ChatDisplay extends StatelessWidget {
  const ChatDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: ChatScreen(
      currentUserId: '1',
      currentUserName: 'Admin',
    ));
  }
}
