import 'package:coffee_card/api_request/announcement_request.dart';
import 'package:coffee_card/arguments/announcement_create_arg.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/providers/announcement_info_provider.dart';
import 'package:coffee_card/providers/announcement_provider.dart';
import 'package:coffee_card/providers/user_provider.dart';
import 'package:coffee_card/screens/announcement_creation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AnnouncementInfo extends StatefulWidget {
  final String? id;
  const AnnouncementInfo({super.key, required this.id});

  @override
  State<AnnouncementInfo> createState() => _AnnouncementInfo();
}

class _AnnouncementInfo extends State<AnnouncementInfo> {
  late AnnouncementInfoProvider announcementInfoProvider;
  late UserProvider userProvider;
  late String id;
  bool isInitialized = false; // Prevents unnecessary re-fetching

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      id = widget.id!;
      announcementInfoProvider =
          Provider.of<AnnouncementInfoProvider>(context, listen: false);

      // Fetch data only once
      announcementInfoProvider.fetchAnnouncementDetails(id);

      isInitialized = true;
    }
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
        title: const Text(
          'Announcement',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: Consumer<AnnouncementInfoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: <Widget>[
              AnnouncementDetailsWidget(
                announcement: provider.announcementDetails,
                user: provider.creationUser,
                cachedUser: int.parse(provider.userId!),
                roleid: int.parse(provider.roleid!),
                id: id,
              )
            ],
          );
        },
      ),
    );
  }
}

class AnnouncementDetailsWidget extends StatelessWidget {
  final AnnouncementModel? announcement;
  final UserModel? user;
  final int cachedUser;
  final int roleid;
  final String? id;

  const AnnouncementDetailsWidget(
      {super.key,
      required this.announcement,
      required this.user,
      required this.cachedUser,
      required this.roleid,
      required this.id});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMM d, yyyy')
        .format(DateTime.parse(announcement!.createddate!));
    bool match = cachedUser == user?.id && roleid == 5;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Event Title
          
          const SizedBox(height: 10),
          // User Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Text(
                  user!.username[0].toUpperCase(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user!.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Visibility(
                  visible: match,
                  child: PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: InkWell(
                          onTap: () async {
                            Navigator.of(context).pop();
                            final ancProvider =
                                Provider.of<AnnouncementProvider>(context,
                                    listen: false);
                            await deleteAnnouncement(int.parse(id!));
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            await ancProvider.fetchAnnouncements();
                          },
                          child: const Text("Delete Announcement"),
                        ),
                      ),
                      PopupMenuItem(
                        child: InkWell(
                          onTap: () async {
                            final ancInfoProvider =
                                Provider.of<AnnouncementInfoProvider>(context,
                                    listen: false);
                            await Navigator.pushNamed(
                                context, AnnouncementCreationScreen.routeName,
                                arguments:
                                    AnnouncementCreateArg(true, announcement!));
                            if (context.mounted) Navigator.of(context).pop();
                            ancInfoProvider
                                .fetchAnnouncementDetails(id!);
                          },
                          child: const Text("Update Announcement"),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
          Text(
            announcement!.title!,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Event Description
          Text(
            announcement!.content!,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
