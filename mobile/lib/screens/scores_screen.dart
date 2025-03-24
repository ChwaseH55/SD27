import 'dart:developer';
import 'dart:io';

import 'package:coffee_card/arguments/announcement_create_arg.dart';
import 'package:coffee_card/arguments/announcementargument.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:coffee_card/providers/announcement_provider.dart';
import 'package:coffee_card/screens/announcement_creation.dart';
import 'package:coffee_card/screens/announcement_info.dart';
import 'package:coffee_card/widgets/announcement_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GolfScoreScreen extends StatelessWidget {
  const GolfScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Scores',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.account_circle_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/pro');
              },
            )
          ],
        ),
        backgroundColor: Colors.grey[100], // Light background
        body: const TournamentList());
  }
}

class TournamentList extends StatefulWidget {
  const TournamentList({super.key});

  @override
  State<TournamentList> createState() => _TournamentList();
}

class _TournamentList extends State<TournamentList> {
  late AnnouncementProvider announcementProvider;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    announcementProvider =
        Provider.of<AnnouncementProvider>(context, listen: false);
    announcementProvider.fetchAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(186, 155, 55, 1), width: 2.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                labelText: 'Search Events',
                labelStyle: const TextStyle(color: Colors.black),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<AnnouncementProvider>(
              builder: (context, announcementProvider, child) {
                if (announcementProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredAnnouncements =
                    announcementProvider.announcements.where((announcement) {
                  return announcement.title!
                      .toLowerCase()
                      .contains(searchQuery);
                }).toList();

                if (filteredAnnouncements.isEmpty) {
                  return const Center(
                      child: Text('No matching announcements found.'));
                }

                return ListView.builder(
                  itemCount: filteredAnnouncements.length,
                  itemBuilder: (context, index) {
                    final announcement = filteredAnnouncements[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AnnouncementInfo.routeName,
                          arguments: AnnouncementArgument(
                              announcement.announcementid!),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: PostWidget(
                          postName: 'Name',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PostWidget extends StatefulWidget {
  final String postName;
  const PostWidget({super.key, required this.postName});

  @override
  State<PostWidget> createState() => _PostWidget();
}

class _PostWidget extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 3.0, color: Colors.black),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /// **Post Title**
              Row(children: <Widget>[
                Text(
                  widget.postName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 7),
              ]),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {showDialog<void>(
                      context: context,
                      builder: (context) => const DialogWid());},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Change this value as needed
                  ),
                ),
                child: const Text(
                  'Submit Scores',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              )

              // /// **Like Button & Actions Row**
            ],
          ),
        ),
      ),
    );
  }
}

class DialogWid extends StatefulWidget {
  const DialogWid({super.key});

  @override
  State<DialogWid> createState() => _DialogWid();
}

class _DialogWid extends State<DialogWid> {
  final _formKey = GlobalKey<FormState>();
  FilePickerResult? result;
  int _count = 1;
  void _addNewContactRow() {
    setState(() {
      _count = _count + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> extractedChildren =
        List.generate(_count, (int i) => const ScoresForm());
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    return AlertDialog(
      title: const Text("Input Scores"),
        content: Stack(clipBehavior: Clip.none, children: <Widget>[
      Positioned(
        left: -30,
        top: -80,
        child: InkResponse(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: Icon(Icons.close, size: 18),
          ),
        ),
      ),
      SizedBox(
          
          child: Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: height * 0.4,
                        constraints: BoxConstraints(maxHeight: height * 0.55),
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          children: extractedChildren,
                        )),
                    Padding(
                        padding: const EdgeInsets.all(4),
                        child: IconButton(
                            icon: const Icon(Icons.add, size: 20,),
                            onPressed: () {
                              _addNewContactRow();
                            })),
                    Padding(
                        padding: const EdgeInsets.all(4),
                        child: ElevatedButton(
                            child: const Text('Submitß'), onPressed: () {})),
                    ElevatedButton(
                      onPressed: () async {
                        result = await FilePicker.platform
                            .pickFiles(allowMultiple: true);
                        if (result == null) {
                          log("No file selected");
                        } else {
                          setState(() {});
                          for (var element in result!.files) {
                            log(element.name);
                          }
                        }
                      },
                      child: const Text("File Picker"),
                    ),
                  ])))
    ]));
  }
}

class ScoresForm extends StatefulWidget {
  const ScoresForm({super.key});

  @override
  State<ScoresForm> createState() => _ScoresForm();
}

class _ScoresForm extends State<ScoresForm> {
  final scoreController = TextEditingController();

  @override
  void dispose() {
    scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        children: [
          DropdownMenu<String>(
            menuHeight: height * 0.3,
            initialSelection: "Item 1",
            dropdownMenuEntries: List.generate(
              10,
              (index) => DropdownMenuEntry(
                value: "Item ${index + 1}",
                label: "Item ${index + 1}",
              ),
            ),
            onSelected: (value) {
              setState(() {});
            },
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.greenAccent),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
