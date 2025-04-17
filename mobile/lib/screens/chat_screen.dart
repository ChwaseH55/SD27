import 'dart:developer';

import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/user_request.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/screens/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    return Scaffold(
        body: user == null
            ? Center(
                child: LoadingAnimationWidget.threeArchedCircle(
                    color: Colors.black, size: 70))
            : ChatScreen(
                currentUserId: user!.id.toString(),
                currentUserName: user!.username.toString(),
              ));
  }
}
