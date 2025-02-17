import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventsWidgets extends StatelessWidget {
  final String? title;
  final String? date;
  final String? message;

  const EventsWidgets({
    super.key,
    required this.title,
    required this.date,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('MMM d, yyyy').format(DateTime.parse(date!));

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
                      title!,
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
                message!,
                style: const TextStyle(fontSize: 16, height: 1.4),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
