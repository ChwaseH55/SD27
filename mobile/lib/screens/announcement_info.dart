import 'package:coffee_card/api_request/announcement_request.dart';
import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/arguments/announcement_create_arg.dart';
import 'package:coffee_card/arguments/announcementargument.dart';
import 'package:coffee_card/arguments/eventcreateargument.dart';
import 'package:coffee_card/arguments/eventsargument.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/providers/announcement_info_provider.dart';
import 'package:coffee_card/providers/announcement_provider.dart';
import 'package:coffee_card/providers/events_info_provider.dart';
import 'package:coffee_card/providers/events_provider.dart';
import 'package:coffee_card/providers/user_provider.dart';
import 'package:coffee_card/screens/announcement_creation.dart';
import 'package:coffee_card/screens/eventcreation.dart';
import 'package:coffee_card/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AnnouncementInfoScreen extends StatelessWidget {
  const AnnouncementInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnouncementInfo();
  }
}

class AnnouncementInfo extends StatefulWidget {
  const AnnouncementInfo({super.key});

  static const routeName = '/extractIdAnnouncement';

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
      final args =
          ModalRoute.of(context)!.settings.arguments as AnnouncementArgument;
      id = args.id.toString();
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

  const AnnouncementDetailsWidget(
      {super.key,
      required this.announcement,
      required this.user,
      required this.cachedUser,
      required this.roleid});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as AnnouncementArgument;
    String formattedDate = DateFormat('MMM d, yyyy')
        .format(DateTime.parse(announcement!.createddate!));
        bool match = cachedUser == user?.id && roleid == 5;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Event Title
          Text(
            announcement!.title!,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                          final ancProvider = Provider.of<AnnouncementProvider>(
                              context,
                              listen: false);
                            await deleteAnnouncement(args.id);
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
                              .fetchAnnouncementDetails(args.id.toString());
                        },
                        child: const Text("Update Announcement"),
                      ),
                    ),
                  ],
                )
              )
            ],
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
