import 'package:flutter/material.dart';

class DiscussionForum extends StatelessWidget {
  const DiscussionForum({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Text(
            'UCF Discussion',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
        ),
      );
  }
}