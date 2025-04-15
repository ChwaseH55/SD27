import 'dart:developer';

import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/screens/chat_widget.dart';
import 'package:flutter/material.dart';

class ChatDisplay extends StatefulWidget {
  const ChatDisplay({super.key});

  @override
  State<ChatDisplay> createState() => _ChatDisplay();
}

class _ChatDisplay extends State<ChatDisplay> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() async {
    var temp = await getUserID();
    final fetchedUser = await getSingleUser(userId: temp!);
    setState(() {
      user = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      // Still loading role
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
        body: ChatScreen(
      currentUserId: user!.id.toString(),
      currentUserName: user!.username.toString(),
    ));
  }
}
