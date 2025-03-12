import 'package:flutter/material.dart';

class AnnouncementdetailsWidget extends StatelessWidget {
  final String posterName;
  final String posterRole;
  final String anncDate;
  final String anncTitle;
  final String anncMessage;
  final String? roleNum;
  final int? userId;
  final int? createdBy;

  const AnnouncementdetailsWidget({
    super.key,
    required this.posterName,
    required this.posterRole,
    required this.anncDate,
    required this.anncTitle,
    required this.anncMessage,
    required this.createdBy,
      required this.roleNum,
      required this.userId
  });

  void handleClick(int item) {
    switch (item) {
      case 0:
        break;
      case 1:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Text(posterName),
                Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(posterRole)),
                const Spacer(),
                PopupMenuButton<int>(
                  onSelected: (item) => handleClick(item),
                  itemBuilder: (context) => [
                    const PopupMenuItem<int>(value: 0, child: Text('One')),
                    const PopupMenuItem<int>(value: 1, child: Text('Two')),
                  ],
                ),
              ],
            )),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Text(
                anncDate,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.black,
                ),
              )
            ],
          )
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              Text(
                anncTitle,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.black),
              )
            ],
          )
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              anncMessage,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 45,
                  color: Colors.black),
            )
          ],
        )
      ],
    );
  }
}
