import 'dart:developer';

import 'package:coffee_card/arguments/regOrAllargument.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/utils.dart';
import 'package:coffee_card/widgets/appBar_widget.dart';
import 'package:coffee_card/widgets/creationformplus.dart';
import 'package:coffee_card/widgets/slideRightTransition.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
  EventsProvider? eventsProvider;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool? isAll;
  bool _isInit = true;
  bool _isLoading = false;
  bool? isRecent = true;
  bool addToCal = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isLoading = true;
      isAll = widget.isAllEvents;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        eventsProvider = Provider.of<EventsProvider>(context, listen: false);
        eventsProvider!.fetchEvents(context);
        if (eventsProvider != null && addToCal) {
          _addToCalendar(context, eventsProvider!.events);
          
        }
      });
      if (mounted) {
        setState(() {
          addToCal = false;
          _isLoading = false;
        });
      }
      _isInit = false;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _addToCalendar(BuildContext context, List<EventsModel> events) {
    for (var event in events) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<EventProvider>(context, listen: false);
        DateTime eventDate = DateTime.parse(event.eventdate!);
        provider.addEvent(eventDate, event.eventname!, event.eventid!);
      });
    }
  }

  void _toggleEventView(bool showAll) {
    setState(() => isAll = showAll);
    eventsProvider!.fetchEvents(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Golf Events',
        showBackButton: true,
        actions: [
          IconButton(
              onPressed: () async {
                await Navigator.pushNamed(context, CreateEvent.routeName,
                    arguments: EventCreateArgument(
                        false, 1, '', '', '', '', false, ''));
                eventsProvider!.fetchEvents(context);
              },
              icon: const Icon(
                Icons.add,
                size: 35,
                color: Colors.black,
              )),
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
        side: BorderSide(
          width: 3.0,
          color: isAllEvents == value ? Colors.black : Colors.transparent,
        ),
        backgroundColor: isAllEvents == value
            ? const Color.fromRGBO(186, 155, 55, 1)
            : Colors.white,
      ),
      child: Text(text,
          style: TextStyle(
              color: isAllEvents == value
                  ? Colors.black
                  : const Color.fromRGBO(186, 155, 55, 1))),
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
