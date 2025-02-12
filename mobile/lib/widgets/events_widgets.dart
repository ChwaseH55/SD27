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
    String formattedDate = DateFormat('MMM d, yyyy').format(DateTime.parse(date!));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child:  Container(
          decoration:  BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 8, bottom: 10, top: 8),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(title!, style: const TextStyle(fontWeight: FontWeight.w700,),),
                    const Spacer(),
                    Text(formattedDate),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[Text(message!)],
                ),
              ],
            ),
          ),
        )
      );
  }
}
