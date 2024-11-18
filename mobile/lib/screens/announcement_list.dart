import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/announcement_widget.dart';
import 'package:coffee_card/widgets/creationformplus.dart';

class AnnouncementList extends StatelessWidget {
  const AnnouncementList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UCF Announcement',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: const AnnouncementListForm(),
      floatingActionButton: const FloatingBtn(),
    );
  }
}

class AnnouncementListForm extends StatefulWidget {
  const AnnouncementListForm({super.key});

  @override
  State<AnnouncementListForm> createState() => _AnnouncementListForm();
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
class _AnnouncementListForm extends State<AnnouncementListForm> {
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

          //Adds announcement
          const AnnouncementWidget(
            title: 'New Gear',
            date: '11/13/24',
            role: 'All',
            message: 'Come get new gear',
          ),
          
        ]);
  }
}
