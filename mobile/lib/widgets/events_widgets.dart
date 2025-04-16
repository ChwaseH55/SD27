import 'dart:developer';

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
  bool? _isRegistered;
  late EventsProvider eventsProvider =
      eventsProvider = Provider.of<EventsProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _isRegistered = widget.isReg!; // Initialize with passed value
  }

  Future<void> _toggleRegistration() async {
    if (_isRegistered!) {
      // Call API to unregister
      await unregisterFromEvent(
          widget.event.eventid.toString(), widget.userId.toString());
      eventsProvider.fetchEvents(context);
    } else {
      // Call API to register
      await registerForEvent(
          widget.event.eventid.toString(), widget.userId.toString());
      eventsProvider.fetchEvents(context);
    }

    setState(() {
      _isRegistered = !_isRegistered!;
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('d').format(DateTime.parse(widget.event.eventdate!));
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    return TweenAnimationBuilder<Offset>(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        tween: Tween(begin: const Offset(1, 0), end: Offset.zero),
        builder: (context, offset, child) {
          return Transform.translate(
            offset: Offset(offset.dx * width, 0),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: IntrinsicHeight(
            child: Container(
              height: height * 0.16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // important for full height
                children: [
                  // LEFT TIME PANEL
                  Container(
                    width: width * 0.15, // optional fixed width
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(186, 155, 55, 1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('MMM')
                              .format(DateTime.parse(widget.event.eventdate!))
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // RIGHT CONTENT
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Add to calendar
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.event.eventname ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            overflow: TextOverflow.ellipsis,
                            widget.event.eventdescription ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),

                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              height: 34,
                              child: Row(children: [
                                const Spacer(),
                                TextButton(
                                  onPressed: _toggleRegistration,
                                  child: Text(
                                    _isRegistered!
                                        ? '✓ Unregister'
                                        : ' + Register',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: _isRegistered!
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
