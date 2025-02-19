import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/arguments/eventsargument.dart';
import 'package:coffee_card/providers/events_info_provider.dart';
import 'package:coffee_card/providers/events_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventInfoScreen extends StatelessWidget {
  const EventInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EventInfo();
  }
}

class EventInfo extends StatefulWidget {
  const EventInfo({super.key});

  static const routeName = '/extractIdEvent';

  @override
  State<EventInfo> createState() => _EventInfo();
}

class _EventInfo extends State<EventInfo> {
  late EventsInfoProvider eventsInfoProvider;
  late String id;
  bool isInitialized = false; // Prevents unnecessary re-fetching

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments as EventsArgument;
      id = args.id.toString();
      eventsInfoProvider =
          Provider.of<EventsInfoProvider>(context, listen: false);

      // Fetch data only once
      eventsInfoProvider.fetchEventDetails(id);
      isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: Consumer<EventsInfoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: <Widget>[
              EventInfoWidget(
                  eventDate: provider.eventsDetails?.eventdate,
                  eventMessage: provider.eventsDetails?.eventdescription,
                  eventName: provider.eventsDetails?.eventname)
            ],
          );
        },
      ),
    );
  }
}

class EventInfoWidget extends StatelessWidget {
  final String? eventName;
  final String? eventDate;
  final String? eventMessage;

  const EventInfoWidget(
      {super.key,
      required this.eventDate,
      required this.eventMessage,
      required this.eventName});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    String formattedDate = DateFormat('MMM d, yyyy').format(DateTime.parse(eventDate!));
    final args = ModalRoute.of(context)!.settings.arguments as EventsArgument;

    return SizedBox(
      height: height * 0.3,
      width: width,
        child: Column(
          // Removed const here
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 6),
              child: Column(
                children: [
                  Row(children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        eventName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: InkWell(
                            onTap: () async {
                              final eventProvider = Provider.of<EventsProvider>(
                                context,
                                listen: false);
                            await deleteEvent(args.id);
                            if (context.mounted) Navigator.pushNamed(context, '/events');
                            await eventProvider.fetchEvents();
                            },
                            child: const Text("Delete Event"),
                          ),
                        ),
                        PopupMenuItem(
                          child: InkWell(
                            onTap: () {
                              //deleteReply(replyId: replyId.toString());// Close the menu manually
                            },
                            child: const Text("Update Event"),
                          ),
                        ),
                      ],
                    )
                  ]),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(children: <Widget>[const Text('Event Date: ',
                        style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),Text(formattedDate,
                        style: const TextStyle(
                          fontSize: 20,))],),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(eventMessage!,
                        style: const TextStyle(
                          fontSize: 28,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
