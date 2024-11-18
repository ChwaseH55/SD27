import 'package:flutter/material.dart';

class AnnouncementWidget extends StatelessWidget {
  final String title;
  final String date;
  final String role;
  final String message;

  const AnnouncementWidget({
    super.key,
    required this.title,
    required this.date,
    required this.role,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {Navigator.pushNamed(context, '/anncDetail');},
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black),
            bottom: BorderSide(color: Colors.black),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 8, bottom: 10, top: 5),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700,),),
                  const Spacer(),
                  Text(date),
                ],
              ),
              Row(
                children: <Widget>[Text(role)],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[Text(message)],
              ),
            ],
          ),
        ),
      )
    );
  }
}
