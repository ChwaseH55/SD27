import 'dart:developer';

import 'package:coffee_card/arguments/regOrAllargument.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/widgets/creationformplus.dart';
import 'package:coffee_card/widgets/slideRightTransition.dart';
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
  final bool isAllEvents;
  const EventsListScreen({super.key, required this.isAllEvents});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  late EventsProvider eventsProvider;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool? isAll;
  bool _isInit = true;
  bool _isLoading = false;
  bool? isRecent = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isLoading = true;
      isAll = widget.isAllEvents;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        eventsProvider = Provider.of<EventsProvider>(context, listen: false);
        eventsProvider.fetchEvents();
      });
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      _isInit = false;
    }
  }

  void _toggleEventView(bool showAll) {
    setState(() => isAll = showAll);
    eventsProvider.fetchEvents();
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
          ElevatedButton(
            onPressed: () async {
              await Navigator.pushNamed(context, CreateEvent.routeName,
                  arguments:
                      EventCreateArgument(false, 1, '', '', '', '', false, ''));
              eventsProvider.fetchEvents();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12), // Change this value as needed
              ),
            ),
            child: const Text('+ New Event',
                style: TextStyle(color: Colors.white)),
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
              cursorColor: Colors.black,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2.0),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                fillColor: Colors.white,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(186, 155, 55, 1), width: 2.0),
                  borderRadius: BorderRadius.circular(40.0),
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
            isAllEvents: isAll!,
            onToggle: _toggleEventView,
          ),
          Expanded(
              child: EventsWidgetBase(
            isAllEvents: isAll!,
            search: searchQuery,
            isRecent: isRecent!,
          )),
        ],
      ),
    );
  }
}

class ToggleButtons extends StatelessWidget {
  final bool isAllEvents;
  final Function(bool) onToggle;
  const ToggleButtons(
      {required this.isAllEvents, required this.onToggle, super.key});

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
  final bool isRecent;
  const EventsWidgetBase(
      {required this.isAllEvents,
      required this.search,
      required this.isRecent,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<EventsProvider, List<EventsModel>>(
      selector: (_, provider) => provider.getFilteredEvents(
        isAllEvents: isAllEvents,
        search: search,
      ),
      builder: (context, filteredEvents, child) {
        final eventsProvider =
            Provider.of<EventsProvider>(context, listen: false);
        if (filteredEvents.isEmpty) {
          return const Center(child: Text('No matching events found.'));
        }

        return ListView.builder(
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            final event = filteredEvents[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                    context, slideRightRoute(EventInfo(id: event.eventid)));
              },
              child: Selector<EventsProvider, bool>(
                selector: (_, provider) =>
                    provider.isRegList[event.eventid] ?? false,
                builder: (_, isRegistered, __) {
             
                  return EventsWidgets(
                    isReg: isRegistered,
                    event: event,
                    userId: eventsProvider.userId,
                  );
                },
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
    return const Align(
        alignment: Alignment.bottomRight, child: FormAddWidget());
  }
}
