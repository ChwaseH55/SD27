import 'package:coffee_card/api_request/announcement_request.dart';
import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/forum_request.dart';
import 'package:coffee_card/arguments/announcement_create_arg.dart';
import 'package:coffee_card/arguments/postcreateargument.dart';
import 'package:flutter/material.dart';

class AnnouncementCreationScreen extends StatefulWidget {
  const AnnouncementCreationScreen({super.key});

  static const routeName = '/extractAncUpdateInfo';

  @override
  State<AnnouncementCreationScreen> createState() =>
      _AnnouncementCreationScreen();
}

class _AnnouncementCreationScreen extends State<AnnouncementCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CreateAnc());
  }
}

class CreateAnc extends StatelessWidget {
  const CreateAnc({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Annnouncement',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(child: PostCreationWidget()),
      ),
    );
  }
}

class PostCreationWidget extends StatelessWidget {
  const PostCreationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as AnnouncementCreateArg;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              args.isUpdate
                  ? 'Update Annnouncement'
                  : 'Create New Annnouncement',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const AncForm(),
          ],
        ),
      ),
    );
  }
}

class AncForm extends StatefulWidget {
  const AncForm({super.key});

  @override
  State<AncForm> createState() => _AncForm();
}

class _AncForm extends State<AncForm> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  AnnouncementCreateArg? args; // Store argument for use in initState

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments only once
    final AnnouncementCreateArg? receivedArgs =
        ModalRoute.of(context)?.settings.arguments as AnnouncementCreateArg?;
    if (receivedArgs != null) {
      args = receivedArgs;
      titleController.text = args!.isUpdate ? args!.anc.title! : "";
      descriptionController.text = args!.isUpdate ? args!.anc.content! : "";
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Announcement Title',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: args!.isUpdate ? 'Enter title' : 'New Announcement Title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: const Color.fromARGB(255, 240, 235, 235),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Announcement Description',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: const Color.fromARGB(255, 240, 235, 235),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              if (args!.isUpdate) {
                await updateAnnouncement(args!.anc.announcementid!,
                    titleController.text, descriptionController.text);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                String? id = await getUserID();
                await createAnnouncement(
                    titleController.text, descriptionController.text, id!);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: Text(
                args!.isUpdate ? 'Update Announcement' : 'Create Announcement',
                style: const TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }
}
