import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_card/api_request/scores_request.dart';
import 'package:coffee_card/arguments/announcement_create_arg.dart';
import 'package:coffee_card/arguments/announcementargument.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:coffee_card/providers/announcement_provider.dart';
import 'package:coffee_card/providers/events_provider.dart';
import 'package:coffee_card/providers/scores_provider.dart';
import 'package:coffee_card/screens/announcement_creation.dart';
import 'package:coffee_card/screens/announcement_info.dart';
import 'package:coffee_card/utils.dart';
import 'package:coffee_card/widgets/announcement_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GolfScoreScreen extends StatelessWidget {
  const GolfScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min, // Ensures minimal spacing
              children: [
                SizedBox(width: 14),
                Icon(Icons.arrow_back_ios,
                    color: Colors.black, size: 16), // Reduce size if needed

                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
      resizeToAvoidBottomInset: true,
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
            child: Consumer<EventsProvider>(
              builder: (context, eventProvider, child) {
                if (eventProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredEvents = eventProvider.events.where((event) {
                  return event.eventname!.toLowerCase().contains('tour');
                }).toList();

                if (filteredEvents.isEmpty) {
                  return const Center(
                      child: Text('No matching announcements found.'));
                }

                return ListView.builder(
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    return InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: PostWidget(
                          postName: event.eventname!,
                          eventid: event.eventid!,
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
  final int eventid;
  const PostWidget({super.key, required this.postName, required this.eventid});

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
                onPressed: () async {
                  showDialog<void>(
                      context: context,
                      builder: (context) => DialogWid(
                            eventid: widget.eventid,
                          ));
                },
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
  final int eventid;
  const DialogWid({super.key, required this.eventid});

  @override
  State<DialogWid> createState() => _DialogWid();
}

class _DialogWid extends State<DialogWid> {
  final _formKey = GlobalKey<FormState>();
  //int _count = 4;

  @override
  Widget build(BuildContext context) {
    // List<Widget> extractedChildren =
    //     List.generate(_count, (int i) => const ScoresForm());
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    return SingleChildScrollView(
        child: AlertDialog(
      title: const Text("Upload Score Card"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: height * 0.55, // Adjust height to fit inside the dialog
            child: SingleChildScrollView(
              child: ScoresForm(
                eventid: widget.eventid,
              ),
            ),
          ),
          const SizedBox(height: 10), // Adds spacing before buttons
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Closes the dialog
          },
          child: const Text(
            "Close",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ));
  }
}

class ScoresForm extends StatefulWidget {
  final int eventid;
  const ScoresForm({super.key, required this.eventid});

  @override
  State<ScoresForm> createState() => _ScoresForm();
}

class _ScoresForm extends State<ScoresForm> {
  late ScoresProvider scoreProvider;
  final scoreController = TextEditingController();
  final scoreController2 = TextEditingController();
  final scoreController3 = TextEditingController();
  final scoreController4 = TextEditingController();
  String val = '';
  String val2 = '';
  String val3 = '';
  String val4 = '';
  FilePickerResult? result;
  List<String> resScores = [];
  List<String> resIds = [];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    scoreController.dispose();
    scoreController2.dispose();
    scoreController3.dispose();
    scoreController4.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scoreProvider = Provider.of<ScoresProvider>(context, listen: false);
    scoreProvider.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Player 1',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          DropdownMenu<String>(
            menuHeight: height * 0.3,
            initialSelection: scoreProvider.users.isNotEmpty
                ? scoreProvider.users.first.username
                : null, // Set initial selection
            dropdownMenuEntries: scoreProvider.users.map((user) {
              return DropdownMenuEntry(
                value:
                    user.id.toString(), // Use user ID or another unique field
                label: user.username, // Display user name
              );
            }).toList(),
            onSelected: (value) {
              val = value!;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              width: width * 0.28,
              child: TextFormField(
                controller: scoreController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(186, 155, 55, 1)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Player 2',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          DropdownMenu<String>(
            menuHeight: height * 0.3,
            initialSelection: scoreProvider.users.isNotEmpty
                ? scoreProvider.users.first.username
                : null, // Set initial selection
            dropdownMenuEntries: scoreProvider.users.map((user) {
              return DropdownMenuEntry(
                value:
                    user.id.toString(), // Use user ID or another unique field
                label: user.username, // Display user name
              );
            }).toList(),
            onSelected: (value) {
              val2 = value!;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              width: width * 0.28,
              child: TextFormField(
                controller: scoreController2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(186, 155, 55, 1)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Player 3',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          DropdownMenu<String>(
            menuHeight: height * 0.3,
            initialSelection: scoreProvider.users.isNotEmpty
                ? scoreProvider.users.first.username
                : null, // Set initial selection
            dropdownMenuEntries: scoreProvider.users.map((user) {
              return DropdownMenuEntry(
                value:
                    user.id.toString(), // Use user ID or another unique field
                label: user.username, // Display user name
              );
            }).toList(),
            onSelected: (value) {
              val3 = value!;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              width: width * 0.28,
              child: TextFormField(
                controller: scoreController3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(186, 155, 55, 1)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Player 4',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          DropdownMenu<String>(
            menuHeight: height * 0.3,
            initialSelection: scoreProvider.users.isNotEmpty
                ? scoreProvider.users.first.username
                : null, // Set initial selection
            dropdownMenuEntries: scoreProvider.users.map((user) {
              return DropdownMenuEntry(
                value:
                    user.id.toString(), // Use user ID or another unique field
                label: user.username, // Display user name
              );
            }).toList(),
            onSelected: (value) {
              val4 = value!;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(
              width: width * 0.28,
              child: TextFormField(
                controller: scoreController4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(186, 155, 55, 1)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () async {
              result = await FilePicker.platform.pickFiles(allowMultiple: true);
              if (result == null) {
                log("No file selected");
              } else {
                setState(() {});
                for (var element in result!.files) {
                  log(element.name);
                }
              }
            },
            icon: const Icon(
              Icons.upload_file_outlined,
              color: Colors.black,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12), // Change this value as needed
              ),
            ),
            label: const Text(
              "File Picker",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(4),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          12), // Change this value as needed
                    ),
                  ),
                  onPressed: () async {
                    if (scoreController.text == '' ||
                        scoreController2.text == '' ||
                        scoreController3.text == '' ||
                        scoreController4.text == '') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Fill out scores for all players')));
                    } else {
                      if (val == '' || val2 == '' || val3 == '' || val4 == '') {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('For each score select a player')));
                      } else if (result == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please input a file')));
                      } else {
                        resScores = [
                          scoreController.text,
                          scoreController2.text,
                          scoreController3.text,
                          scoreController4.text
                        ];
                        resIds = [(val), val2, val3, val4];

                        String? eventid = widget.eventid.toString();
                        File file = File(result!.files.single.path!);
                        String fileName =
                            "${DateTime.now().millisecondsSinceEpoch}_${result!.files.single.name}";

                        // 🟢 Step 2: Create Firebase Storage reference
                        Reference storageRef = FirebaseStorage.instance
                            .ref()
                            .child("score_images/$eventid/$fileName");

                        // 🟢 Step 3: Upload file
                        UploadTask uploadTask = storageRef.putFile(file);
                        TaskSnapshot snapshot = await uploadTask;

                        // 🟢 Step 4: Get Download URL
                        String downloadUrl =
                            await snapshot.ref.getDownloadURL();
                        log("File uploaded! Download URL: $downloadUrl");

                        bool res = await uploadScore(
                            eventId: widget.eventid.toString(),
                            scores: resScores,
                            userIds: resIds,
                            scoreImage: downloadUrl);
                        if (res) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Scores upload')));
                            Navigator.pop(context);
                          }
                        }
                      }
                    }
                  },
                  child: const Text(
                    'Submit Scores',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  )))
        ],
      ),
    );
  }
}
