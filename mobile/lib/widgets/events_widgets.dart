import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/models/events_model.dart';
import 'package:coffee_card/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventsWidgets extends StatelessWidget {
final EventsModel event;
final String? userId;

  const EventsWidgets({
    super.key,
    required this.event,
    required this.userId
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('MMM d, yyyy').format(DateTime.parse(event.eventdate!));
    

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
                      event.eventname!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                event.eventdescription!,
                style: const TextStyle(fontSize: 16, height: 1.4),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 10),
              
             Visibility(
              visible: event.createdbyuserid == int.parse(userId!),
               child: SizedBox(
                 height: 30,
                 child: ElevatedButton(
                   onPressed: () {
                     EventProvider provider = Provider.of<EventProvider>(context, listen: false);
                     DateTime eventDate =
                         DateTime.parse(event.eventdate!); // Convert date to DateTime
                     provider.addEvent(eventDate, event.eventname!, event.eventid!); // Add event to kEvents
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text("Event added to calendar!")),
                     );
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
                     padding: const EdgeInsets.symmetric(horizontal: 5),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(10),
                     ),
                   ),
                   child: const Text(
                     'Add to Calendar',
                     style: TextStyle(fontSize: 12, color: Colors.black),
                   ),
                 ),
               )
             ),
            ],
          ),
        ),
      ),
    );
  }
}
