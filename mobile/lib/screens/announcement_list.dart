import 'package:coffee_card/arguments/announcement_create_arg.dart';
import 'package:coffee_card/arguments/announcementargument.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:coffee_card/providers/announcement_provider.dart';
import 'package:coffee_card/screens/announcement_creation.dart';
import 'package:coffee_card/screens/announcement_info.dart';
import 'package:coffee_card/widgets/events_widgets.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/announcement_widget.dart';
import 'package:coffee_card/widgets/creationformplus.dart';
import 'package:provider/provider.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreen();
}

class _AnnouncementListScreen extends State<AnnouncementListScreen> {
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
        title: const Text('Golf Announcements',
            style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
        actions: [
          Visibility(
              visible: announcementProvider.roleid == '5',
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                ),
                onPressed: () async {
                  await Navigator.pushNamed(
                    context,
                    AnnouncementCreationScreen.routeName,
                    arguments:
                        AnnouncementCreateArg(false, AnnouncementModel()),
                  );
                  // Force refresh after returning from create post screen
                  announcementProvider.fetchAnnouncements();
                },
                child: const Text('+ Create'),
              )),
        ],
      ),
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
                    if (index == filteredAnnouncements.length - 1) {
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AnnouncementInfo.routeName,
                            arguments: AnnouncementArgument(
                                announcement.announcementid!),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.black),
                              ),
                            ),
                            child: AnnouncementWidget(
                              announcement: announcement,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AnnouncementInfo.routeName,
                            arguments: AnnouncementArgument(
                                announcement.announcementid!),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: AnnouncementWidget(
                            announcement: announcement,
                          ),
                        ),
                      );
                    }
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
