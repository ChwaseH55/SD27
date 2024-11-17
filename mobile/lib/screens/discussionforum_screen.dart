import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/forum_widget.dart';

class DiscussionForum extends StatelessWidget {
  const DiscussionForum({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UCF Discussion',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: const DiscussionForumForm(),
    );
  }
}

class DiscussionForumForm extends StatefulWidget {
  const DiscussionForumForm({super.key});

  @override
  State<DiscussionForumForm> createState() => _DiscussionForumForm();
}

// This class holds the data related to the Form.
class _DiscussionForumForm extends State<DiscussionForumForm> {
  final searchController = TextEditingController();
  
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          // Search input
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

          const ForumWidget(
            forumName: 'Name',
            forumNumber: 89,
          ),
          
        ]);
  }
}