import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/announcementdetails_widget.dart';

class AnnouncementdetailScreen extends StatelessWidget {
  const AnnouncementdetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UCF Announcement',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      
      );
    
  }
}

