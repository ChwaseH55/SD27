import 'package:coffee_card/models/announcement_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnnouncementWidget extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementWidget({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMM d, yyyy')
        .format(DateTime.parse(announcement.createddate!));

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black),
          
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 8, bottom: 10, top: 5),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  announcement.title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(formattedDate),
              ],
            ),
            const Row(
              children: <Widget>[],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  // Wrap text in Expanded
                  child: Text(
                    announcement.content!,
                    maxLines: 1,
                  
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
