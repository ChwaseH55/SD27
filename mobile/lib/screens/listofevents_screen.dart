import 'package:coffee_card/arguments/regOrAllargument.dart';
import 'package:coffee_card/widgets/creationformplus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coffee_card/providers/events_provider.dart';
import 'package:coffee_card/screens/event_info.dart';
import 'package:coffee_card/arguments/eventsargument.dart';
import 'package:coffee_card/widgets/events_widgets.dart';
import 'package:coffee_card/screens/eventcreation.dart';
import 'package:coffee_card/arguments/eventcreateargument.dart';

class EventsListScreen extends StatefulWidget {
  static const routeName = '/extractIsRegOrAll';
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  late EventsProvider eventsProvider;
  bool isAllEvents = true;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as IsAllOrReg?;
    isAllEvents = args?.boolean ?? true;
    eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    eventsProvider.fetchEvents();
  }

  void _toggleEventView(bool showAll) {
    setState(() => isAllEvents = showAll);
    eventsProvider.fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UCF Events', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
        actions: [
          if (eventsProvider.roleid == '5')
            TextButton(
              onPressed: () async {
                await Navigator.pushNamed(context, CreateEvent.routeName,
                    arguments: EventCreateArgument(false, 1, '', '', '', '', false, ''));
                eventsProvider.fetchEvents();
              },
              child: const Text('+ New Event', style: TextStyle(color: Colors.black)),
            ),
        ],
      ),
      floatingActionButton: const FloatingBtn(),
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
          ToggleButtons(
            isAllEvents: isAllEvents,
            onToggle: _toggleEventView,
          ),
          Expanded(child: EventsWidgetBase(isAllEvents: isAllEvents, search: searchQuery,)),
        ],
      ),
    );
  }
}

class ToggleButtons extends StatelessWidget {
  final bool isAllEvents;
  final Function(bool) onToggle;
  const ToggleButtons({required this.isAllEvents, required this.onToggle, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton('All Events', true),
        const SizedBox(width: 10),
        _buildButton('Registered Events', false),
      ],
    );
  }

  Widget _buildButton(String text, bool value) {
    return ElevatedButton(
      onPressed: () => onToggle(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: isAllEvents == value
            ? const Color.fromRGBO(186, 155, 55, 1)
            : const Color.fromARGB(255, 147, 122, 39),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black)),
    );
  }
}

class EventsWidgetBase extends StatelessWidget {
  final bool isAllEvents;
  final String search;
  const EventsWidgetBase({required this.isAllEvents, required this.search, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        if (eventsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = isAllEvents ? eventsProvider.events : eventsProvider.registeredevents;

        final filteredEvents = events.where((event) {
                return event.eventname!.toLowerCase().contains(search);
              }).toList();

              if (filteredEvents.isEmpty) {
                return const Center(child: Text('No matching events found.'));
              }

        return ListView.builder(
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            final event = filteredEvents[index];
            return InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  EventInfo.routeName,
                  arguments: EventsArgument(event.eventid!),
                );
              },
              child: EventsWidgets(
                isReg: eventsProvider.isRegList[event.eventid],
                event: event,
                userId: eventsProvider.userId,
              ),
            );
          },
        );
      },
    );
  }
}

class FloatingBtn extends StatelessWidget {
  const FloatingBtn({super.key});
  @override
  Widget build(BuildContext context) {
    return const Align(alignment: Alignment.bottomRight, child: FormAddWidget());
  }
}
