import 'package:coffee_card/models/announcement_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppBarWidget extends StatelessWidget {
  final String screenTitle;
  final FontWeight fontWeight;
  final double fontSize;

  const AppBarWidget({super.key, required this.screenTitle,required this.fontSize,required this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(35.0),
      child: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min, // Ensures minimal spacing
            children: [
              SizedBox(width: 14),
              Icon(Icons.arrow_back_ios,
                  color: Colors.black, size: 16), // Reduce size if needed
                Text(
                'Back',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        title:  Text(screenTitle,
            style:  TextStyle(fontWeight: fontWeight, fontSize: fontSize)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      )
    );
  }
}
