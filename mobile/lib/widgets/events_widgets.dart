import 'package:coffee_card/providers/events_provider.dart';
import 'package:coffee_card/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/api_request/events_request.dart'; // Assuming this contains API calls

class EventsWidgets extends StatefulWidget {
  final bool? isReg;
  final EventsModel event;
  final String? userId;

  const EventsWidgets({
    super.key,
    required this.isReg,
    required this.event,
    required this.userId,
  });

  @override
  _EventsWidgetsState createState() => _EventsWidgetsState();
}

class _EventsWidgetsState extends State<EventsWidgets> {
  late bool _isRegistered;
  bool _isAddedToCalendar = false;
  late EventsProvider eventsProvider = eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    

  @override
  void initState() {
    super.initState();
    _isRegistered = widget.isReg!; // Initialize with passed value
  }

  Future<void> _toggleRegistration() async {
    if (_isRegistered) {
      // Call API to unregister
      await unregisterFromEvent(
          widget.event.eventid.toString(), widget.userId.toString());
          eventsProvider.fetchEvents();
          
    } else {
      // Call API to register
      await registerForEvent(
          widget.event.eventid.toString(), widget.userId.toString());
         eventsProvider.fetchEvents();
    }

    setState(() {
      _isRegistered = !_isRegistered;
    });
  }

  void _addToCalendar() {
    EventProvider provider = Provider.of<EventProvider>(context, listen: false);
    DateTime eventDate = DateTime.parse(widget.event.eventdate!);
    provider.addEvent(eventDate, widget.event.eventname!, widget.event.eventid!);
    setState(() {
      _isAddedToCalendar = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event added to calendar!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMM d, yyyy')
        .format(DateTime.parse(widget.event.eventdate!));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.event.eventname!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.event.eventdescription!,
                style: const TextStyle(fontSize: 16, height: 1.4),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  if (widget.event.createdbyuserid == int.parse(widget.userId!))
                    Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          onPressed: _isAddedToCalendar ? null : _addToCalendar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isAddedToCalendar
                                ? Colors.grey
                                : const Color.fromRGBO(186, 155, 55, 1),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _isAddedToCalendar ? 'Added to Calendar' : 'Add to Calendar',
                            style: const TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  // Register / Unregister button
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: _toggleRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRegistered ? Colors.red : Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _isRegistered ? 'Unregister' : 'Register',
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
