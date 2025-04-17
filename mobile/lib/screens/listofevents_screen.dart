import 'package:coffee_card/api_request/auth_request.dart';
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
  static final Set<String> _addedToCalendarEventIds = {}; // Track by event id or route
  EventsProvider? eventsProvider;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool? isAll;
  bool _isInit = true;
  bool _isLoading = false;
  String? eventSort = '';
  String? role;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isLoading = true;
      isAll = widget.isAllEvents;

      getRoleId().then((fetchedRole) {
        if (mounted) {
          setState(() {
            role = fetchedRole;
          });
        }
      });

      eventsProvider = Provider.of<EventsProvider>(context, listen: false);
      eventsProvider!.fetchEvents(context).then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // ✅ Only add to calendar if not already added for this screen
          final screenId = widget.key?.toString() ?? widget.hashCode.toString();
          if (!_addedToCalendarEventIds.contains(screenId)) {
            _addToCalendar(context, eventsProvider!.events);
            _addedToCalendarEventIds.add(screenId);
          }
        }
      });

      _isInit = false;
    }
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
          if (role == '5')
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
                suffixIcon: Align(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list),
                    onSelected: (String result) {
                      setState(() {
                        switch (result) {
                          case 'recent':
                            eventSort = 'recent';
                            break;
                          case 'old':
                            eventSort = 'old';
                            break;
                          case 'clear':
                            eventSort = 'clear';

                          default:
                        }
                      });
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'recent',
                        child: Text('Upcoming Events'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'old',
                        child: Text('Older Events'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'clear',
                        child: Text('Clear'),
                      ),
                    ],
                  ),
                ),
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
            eventSort: eventSort!,
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
  final String eventSort;
  const EventsWidgetBase(
      {required this.isAllEvents,
      required this.search,
      required this.eventSort,
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

        if (eventsProvider.isLoading) {
          return Center(
            child: LoadingAnimationWidget.threeArchedCircle(
                color: Colors.black, size: 100),
          );
        }

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day); // strips off time

        if (eventSort == 'recent') {
          filteredEvents = eventsProvider.events
              .where((event) => DateTime.parse(event.eventdate!).isAfter(today))
              .toList();
          filteredEvents.sort((a, b) => a.eventdate!.compareTo(b.eventdate!));
        } else if (eventSort == 'old') {
          filteredEvents = eventsProvider.events
              .where(
                  (event) => DateTime.parse(event.eventdate!).isBefore(today))
              .toList();
          filteredEvents.sort((a, b) => b.eventdate!
              .compareTo(a.eventdate!)); // optional: most recent old first
        } else if (eventSort == 'clear') {
          filteredEvents = List.from(eventsProvider.events); // restore original
        }

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
