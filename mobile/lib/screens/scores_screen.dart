import 'dart:developer';
import 'dart:io';

import 'package:coffee_card/api_request/scores_request.dart';
import 'package:coffee_card/providers/announcement_provider.dart';
import 'package:coffee_card/providers/events_provider.dart';
import 'package:coffee_card/providers/scores_provider.dart';
import 'package:coffee_card/widgets/appBar_widget.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GolfScoreScreen extends StatelessWidget {
  const GolfScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: 'Score Upload', showBackButton: true,),
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
  EventsProvider? eventsProvider;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  bool _isInit = true;
  bool _isLoading = false;
  bool? isRecent = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        eventsProvider = Provider.of<EventsProvider>(context, listen: false);
        eventsProvider!.fetchEvents(context);
      });
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      _isInit = false;
    }
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
              cursorColor: Colors.black,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2.0),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                fillColor: Colors.white,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(186, 155, 55, 1), width: 2.0),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                labelText: 'Search Tournaments',
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
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return DialogWid(eventid: widget.eventid);
                    },
                  );
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
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: ScoresForm(eventid: widget.eventid),
        ),
      ),
    );
  }
}

class ScoresForm extends StatefulWidget {
  final int eventid;
  const ScoresForm({super.key, required this.eventid});

  @override
  State<ScoresForm> createState() => _ScoresFormState();
}

class _ScoresFormState extends State<ScoresForm> {
  late ScoresProvider scoreProvider;
  FilePickerResult? result;
  final List<TextEditingController> scoreControllers =
      List.generate(4, (_) => TextEditingController());
  final List<String> selectedUserIds = List.filled(4, '');
  bool uploadedImage = false;

  @override
  void dispose() {
    for (var controller in scoreControllers) {
      controller.dispose();
    }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Upload Score Card',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildFileUploadCard(),
        const SizedBox(height: 16),
        const Text(
          'Player Scores',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildPlayerFormCard(),
        const SizedBox(height: 20),
        _buildButtonRow(),
      ],
    );
  }

  Widget _buildFileUploadCard() {
    return GestureDetector(
        onTap: () async {
          result = await FilePicker.platform.pickFiles(allowMultiple: true);
          if (result == null) {
            log("No file selected");
          } else {
            setState(() {
              uploadedImage = true;
            });
            for (var element in result!.files) {
              log(element.name);
            }
          }
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(12),
          dashPattern: const [6, 3],
          color: uploadedImage ? Colors.green : Colors.grey,
          child: Container(
              width: double.infinity,
              height: 140,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      uploadedImage
                          ? Icons.check_circle_rounded
                          : Icons.image_outlined,
                      size: 40,
                      color: uploadedImage ? Colors.green : Colors.grey),
                  const SizedBox(height: 8),
                  uploadedImage
                      ? const Text('Successful Upload', style: TextStyle(color: Colors.green),)
                      : const Text('Click here to upload score card'),
                   Text('Maximum file size: 5MB',
                      style: TextStyle(fontSize: 12, color: uploadedImage ?Colors.green : Colors.black)),
                ],
              )),
        ));
  }


  Widget _buildPlayerFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Player ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(flex: 2, child: _buildDropdown(index)),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: scoreControllers[index],
                        decoration: const InputDecoration(
                          hintText: 'Score',
                          isDense: true,
                          border: OutlineInputBorder(),
                          focusColor: Color.fromRGBO(186, 155, 55, 1)
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDropdown(int index) {
    return DropdownButtonFormField<String>(
   
    
      isExpanded: true,
      value: selectedUserIds[index].isNotEmpty ? selectedUserIds[index] : null,
      items: scoreProvider.users.map((user) {
        return DropdownMenuItem(
          value: user.id.toString(),
          child: Text(user.username),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => selectedUserIds[index] = value ?? '');
      },
      decoration: const InputDecoration(
        focusColor: Color.fromRGBO(186, 155, 55, 1),
        hintText: 'Select Player',
        isDense: true,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _submitScores,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
          ),
          child:
              const Text('Submit Score', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Future<void> _submitScores() async {
    if (scoreControllers.any((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill out scores for all players')));
      return;
    }

    if (selectedUserIds.any((id) => id.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('For each score select a player')));
      return;
    }

    if (result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please input a file')));
      return;
    }

    final resScores = scoreControllers.map((c) => c.text).toList();
    final resIds = List<String>.from(selectedUserIds);
    final String eventid = widget.eventid.toString();

    final file = File(result!.files.single.path!);
    final fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${result!.files.single.name}";
    final storageRef =
        FirebaseStorage.instance.ref().child("score_images/$eventid/$fileName");
    final snapshot = await storageRef.putFile(file);

    final downloadUrl = await snapshot.ref.getDownloadURL();
    log("File uploaded! Download URL: $downloadUrl");
    log('${widget.eventid.toString()}');
    log('${resScores}');
    log('$resIds');
    log('$downloadUrl');
    // final success = await uploadScore(
    //   eventId: widget.eventid.toString(),
    //   scores: resScores,
    //   userIds: resIds,
    //   scoreImage: downloadUrl,
    // );

    // if (success && context.mounted) {
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(const SnackBar(content: Text('Scores uploaded')));
    //   Navigator.pop(context);
    // }
  }
}
