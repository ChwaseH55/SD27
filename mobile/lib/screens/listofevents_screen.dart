import 'package:coffee_card/arguments/eventsargument.dart';
import 'package:coffee_card/providers/events_provider.dart';
import 'package:coffee_card/providers/forum_provider.dart';
import 'package:coffee_card/screens/event_info.dart';
import 'package:coffee_card/widgets/events_widgets.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/post_discussion_widget.dart';
import 'package:coffee_card/widgets/creationformplus.dart';
import 'package:coffee_card/arguments/postargument.dart';
import 'package:coffee_card/screens/disscusisonpost_info.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreen();
}

class _EventsListScreen extends State<EventsListScreen> {
  late EventsProvider eventsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetch latest posts when screen is revisited
    eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    eventsProvider.fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UCF Events',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
        actions: [
          TextButton(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
            ),
            onPressed: () async {
              Navigator.pushNamed(context, '/createEvent');
           
            },
            child: const Text('+ Create Event'),
          ),
        ],
      ),
      body: const PostsScreen(),
      floatingActionButton: const FloatingBtn(),
    );
  }
}

class FloatingBtn extends StatelessWidget {
  const FloatingBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
        alignment: Alignment.bottomRight, child: FormAddWidget());
  }
}

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        if (eventsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (eventsProvider.events.isEmpty) {
          return const Center(child: Text('No events found.'));
        }

        return Padding(
            padding: const EdgeInsets.only(top: 5),
            child: ListView.builder(
              itemCount: eventsProvider.events.length,
              itemBuilder: (context, index) {
                final event = eventsProvider.events[index];
                return InkWell(
                    onTap: () {
                      log('enter');
                      Navigator.pushNamed(
                        context,
                        EventInfo.routeName,
                        arguments: EventsArgument(event.eventid!),
                      );
                    },
                    child: EventsWidgets(
                        title: event.eventname,
                        date: event.eventdate,
                        message: event.eventdescription));
              },
            ));
      },
    );
  }
}
