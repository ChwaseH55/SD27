import 'package:coffee_card/api_request/events_request.dart';
import 'package:coffee_card/arguments/eventcreateargument.dart';
import 'package:coffee_card/screens/eventcreation.dart';
import 'package:coffee_card/widgets/creationformplus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_card/providers/events_provider.dart';
import 'package:coffee_card/screens/event_info.dart';
import 'package:coffee_card/arguments/eventsargument.dart';
import 'package:coffee_card/widgets/events_widgets.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  late EventsProvider eventsProvider;
  Widget _selectedWidget = const AllEventsWidget();
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    eventsProvider.fetchEvents();
  }

    void _showAllEvents() async {
    setState(() {
      _selectedWidget = const AllEventsWidget();
    });
   
            await eventsProvider.fetchEvents();                    
  }

  void _showAnotherWidget() async {
    setState(() {
      _selectedWidget = const RegisteredEventsWidget(); 
    });
    await eventsProvider.fetchEvents();    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('UCF Events',
              style: TextStyle(fontWeight: FontWeight.w900)),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
          actions: [
            Visibility(
              visible: eventsProvider.roleid == '5',
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                ),
                onPressed: () async {
                  await Navigator.pushNamed(context, CreateEvent.routeName,
                      arguments: EventCreateArgument(
                          false, 1, '', '', '', '', false, ''));
                  eventsProvider.fetchEvents();
                },
                child: const Text('+ New Event'),
              )
            ),
          ],
        ),
        floatingActionButton: const FloatingBtn(),
        body: Column(
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     ElevatedButton(
          //       onPressed: _showAllEvents,
          //       style: ElevatedButton.styleFrom(
          //                   backgroundColor:
          //                       const Color.fromRGBO(186, 155, 55, 1),
          //                   padding: const EdgeInsets.symmetric(horizontal: 5),
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(10),
          //                   ),
          //                 ),
          //                 child: const Text(
          //                   'All Events',
          //                   style: TextStyle(fontSize: 12, color: Colors.black),
          //                 ),
          //     ),
          //     const SizedBox(width: 10),
          //     ElevatedButton(
          //       onPressed: _showAnotherWidget,
          //       style: ElevatedButton.styleFrom(
          //                   backgroundColor:
          //                       const Color.fromRGBO(186, 155, 55, 1),
          //                   padding: const EdgeInsets.symmetric(horizontal: 5),
          //                   shape: RoundedRectangleBorder(
          //                     borderRadius: BorderRadius.circular(10),
          //                   ),
          //                 ),
          //                 child: const Text(
          //                   'Registered Event',
          //                   style: TextStyle(fontSize: 12, color: Colors.black),
          //                 ),
          //     ),
          //   ],
          // ),
          Expanded(child: _selectedWidget),
        ],
      ),
    );
  }
}

class AllEventsWidget extends StatefulWidget {
  const AllEventsWidget({super.key});

  @override
  State<AllEventsWidget> createState() => _AllEventsWidget();
}

class _AllEventsWidget extends State<AllEventsWidget> {
  late EventsProvider eventsProvider;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
Widget build(BuildContext context) {
  return Column(
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
      // Add the buttons here
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => context.findAncestorStateOfType<_EventsListScreenState>()?._showAllEvents(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'All Events',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => context.findAncestorStateOfType<_EventsListScreenState>()?._showAnotherWidget(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Registered Event',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ],
      ),
      Expanded(
        child: Consumer<EventsProvider>(
          builder: (context, eventsProvider, child) {
            if (eventsProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final filteredEvents = eventsProvider.events.where((event) {
              return event.eventname!.toLowerCase().contains(searchQuery);
            }).toList();

            if (filteredEvents.isEmpty) {
              return const Center(child: Text('No matching events found.'));
            }

            return ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return FutureBuilder<bool>(
                  future: checkReg(event.eventid.toString(), eventsProvider.userId.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          EventInfo.routeName,
                          arguments: EventsArgument(event.eventid!),
                        );
                      },
                      child: EventsWidgets(
                        isReg: snapshot.data,
                        event: event,
                        userId: eventsProvider.userId,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    ],
  );
}

  }


Future<bool> checkReg(eventid,userid) async {
  return await isUserRegisteredForEvent(eventid,userid); 
}

class RegisteredEventsWidget extends StatefulWidget {
  const RegisteredEventsWidget({super.key});

  @override
  State<RegisteredEventsWidget> createState() => _RegisteredEventsWidget();
}

class _RegisteredEventsWidget extends State<RegisteredEventsWidget> {
  late EventsProvider eventsProvider;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

   @override
Widget build(BuildContext context) {
  return Column(
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
      // Add the buttons here
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => context.findAncestorStateOfType<_EventsListScreenState>()?._showAllEvents(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'All Events',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => context.findAncestorStateOfType<_EventsListScreenState>()?._showAnotherWidget(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Registered Event',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ],
      ),
      Expanded(
        child: Consumer<EventsProvider>(
          builder: (context, eventsProvider, child) {
            if (eventsProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final filteredEvents = eventsProvider.registeredevents.where((event) {
              return event.eventname!.toLowerCase().contains(searchQuery);
            }).toList();

            if (filteredEvents.isEmpty) {
              return const Center(child: Text('No matching events found.'));
            }

            return ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return FutureBuilder<bool>(
                  future: checkReg(event.eventid.toString(), eventsProvider.userId.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          EventInfo.routeName,
                          arguments: EventsArgument(event.eventid!),
                        );
                      },
                      child: EventsWidgets(
                        isReg: snapshot.data,
                        event: event,
                        userId: eventsProvider.userId,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    ],
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
