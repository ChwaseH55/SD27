import 'package:coffee_card/widgets/forumcreation_widget.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/post_discussion_widget.dart';
import 'package:coffee_card/widgets/creationformplus.dart';

class ForumpostScreen extends StatelessWidget {
  const ForumpostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UCF Post',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: const ForumPostForm(),
      floatingActionButton: const FloatingBtn(),
    );
  }
}

class ForumPostForm extends StatefulWidget {
  const ForumPostForm({super.key});

  @override
  State<ForumPostForm> createState() => _ForumPostForm();
}

class FloatingBtn extends StatelessWidget {
  const FloatingBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
        alignment: Alignment.bottomRight, child: FormAddWidget());
  }
}

// This class holds the data related to the Form.
class _ForumPostForm extends State<ForumPostForm> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Username input
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Search',
                ),
              ),
            ),
          ),

          const PostWidget(
            postName: 'Name',
            postNumber: 89,
            likeNumber: 90,
          ),
        ]);
  }
}
