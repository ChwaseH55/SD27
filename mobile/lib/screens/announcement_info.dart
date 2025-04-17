import 'package:coffee_card/api_request/announcement_request.dart';
import 'package:coffee_card/arguments/announcement_create_arg.dart';
import 'package:coffee_card/models/announcement_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/providers/announcement_info_provider.dart';
import 'package:coffee_card/providers/announcement_provider.dart';
import 'package:coffee_card/providers/user_provider.dart';
import 'package:coffee_card/screens/announcement_creation.dart';
import 'package:coffee_card/widgets/appBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
      appBar: const CustomAppBar(
        title: 'Announcement Details',
        showBackButton: true,
      ),
      body: Consumer<AnnouncementInfoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
            child: LoadingAnimationWidget.threeArchedCircle(
                color: Colors.black, size: 100),
          );
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
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Event Title

          const SizedBox(height: 10),
          // User Info Row
          Row(
            children: [
             Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(229, 191, 69, 1),
                          Color.fromRGBO(137, 108, 14, 1)
                        ],
                      ),
                    ),
                    child:  CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.transparent,
                            child: Text(
                              user!.username[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        
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
                            ancInfoProvider.fetchAnnouncementDetails(id!);
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
