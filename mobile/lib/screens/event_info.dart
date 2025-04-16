import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/arguments/eventcreateargument.dart';
import 'package:coffee_card/arguments/eventsargument.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/models/user_model.dart';
import 'package:coffee_card/providers/events_info_provider.dart';
import 'package:coffee_card/providers/events_provider.dart';
import 'package:coffee_card/providers/user_provider.dart';
import 'package:coffee_card/screens/eventcreation.dart';
import 'package:coffee_card/utils.dart';
import 'package:coffee_card/widgets/appBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventInfo extends StatefulWidget {
  final int? id;
  const EventInfo({super.key, required this.id});

  static const routeName = '/extractIdEvent';

  @override
  State<EventInfo> createState() => _EventInfo();
}

class _EventInfo extends State<EventInfo> {
  late EventsInfoProvider eventsInfoProvider;
  late UserProvider userProvider;
  String? eventid;
  bool isInitialized = false; // Prevents unnecessary re-fetching

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      eventid = widget.id.toString();
      eventsInfoProvider =
          Provider.of<EventsInfoProvider>(context, listen: false);

      // Fetch data only once
      eventsInfoProvider.fetchEventDetails(eventid!);

      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Event', showBackButton: true,),
      body: Consumer<EventsInfoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: <Widget>[
              EventInfoWidget(
                event: provider.eventsDetails,
                user: provider.creationUser,
                cachedUser: int.parse(provider.userId!),
                roleid: provider.roleid,
                eventid: eventid,
              )
            ],
          );
        },
      ),
    );
  }
}

class EventInfoWidget extends StatelessWidget {
  final EventsModel? event;
  final UserModel? user;
  final int? cachedUser;
  final String? roleid;
  final String? eventid;

  const EventInfoWidget(
      {super.key,
      required this.event,
      required this.user,
      required this.cachedUser,
      required this.roleid,
      required this.eventid});


  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('MMM d, yyyy').format(DateTime.parse(event!.eventdate!));
    bool match = cachedUser == event?.createdbyuserid || roleid == '5';
    ImageProvider<Object>? picture;
    if (user == null) {
      picture = const AssetImage('assets/images/golf_logo.jpg');
    } else if (user!.profilepicture == null) {
      picture = const AssetImage('assets/images/golf_logo.jpg');
    } else {
      picture = NetworkImage(user!.profilepicture!);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Event Title
          Text(
            event!.eventname!,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.black,
                size: 20,
              ),
              const SizedBox(width: 4), // space between icon and text
              Text(
                event!.eventlocation!,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // User Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: picture,
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
                  child: InkWell(
                      child: PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: InkWell(
                          onTap: () async {
                            Navigator.of(context).pop();
                            final eventProvider = Provider.of<EventsProvider>(
                                context,
                                listen: false);
                            EventProvider provider = Provider.of<EventProvider>(
                                context,
                                listen: false);
                            await deleteEvent(int.parse(eventid!));
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            await eventProvider.fetchEvents(context);
                            provider.removEvent(
                                DateTime.parse(event!.eventdate!),
                                int.parse(eventid!));
                          },
                          child: const Row(
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(width: 4), // space between icon and text
                              Text(
                                'Delete Event',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        child: InkWell(
                          onTap: () async {
                            final eventInfoProvider =
                                Provider.of<EventsInfoProvider>(context,
                                    listen: false);
                            final eventListProvider =
                                Provider.of<EventsProvider>(context,
                                    listen: false);
                            await Navigator.pushNamed(
                                context, CreateEvent.routeName,
                                arguments: EventCreateArgument(
                                    true,
                                    int.parse(eventid!),
                                    event!.eventname!,
                                    event!.eventdescription!,
                                    event!.eventlocation!,
                                    event!.eventtype!,
                                    event!.requiresregistration!,
                                    event!.eventdate!));
                            if (context.mounted) Navigator.of(context).pop();
                            eventInfoProvider.fetchEventDetails(eventid!);
                            eventListProvider.fetchEvents(context);
                          },
                          child: const Row(
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(width: 4), // space between icon and text
                              Text(
                                'Edit Event',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // PopupMenuItem(
                      //   child: InkWell(
                      //     onTap: () {
                      //       Navigator.of(context).pop();
                      //       _addToCalendar(context);
                      //     },
                      //     child: const Row(
                      //       children: [
                      //         Icon(
                      //           Icons.event_available,
                      //           color: Colors.black,
                      //           size: 20,
                      //         ),
                      //         SizedBox(width: 4),
                      //         Text(
                      //           'Add to Calendar',
                      //           style: TextStyle(
                      //             fontSize: 14,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  )))
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.tag,
                size: 18,
              ),
              const SizedBox(width: 4), // space between icon and text
              Text(
                event!.eventtype!,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Event Description
          Text(
            event!.eventdescription!,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
