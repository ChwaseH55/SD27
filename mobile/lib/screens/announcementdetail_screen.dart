import 'package:flutter/material.dart';

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
      body: const MainBody(),
    );
  }
}

class MainBody extends StatelessWidget {
  const MainBody({super.key});
  
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
    return Column(children: [
      Row(children: [const Text('sss'), const Spacer(), PopupMenuButton<int>(
          onSelected: (item) => handleClick(item),
          itemBuilder: (context) => [
            const PopupMenuItem<int>(value: 0, child: Text('One')),
            const PopupMenuItem<int>(value: 1, child: Text('Two')),
          ],
        ),],),
      const Row(children: [Text('sss', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30, color: Colors.black, ), )],),
      const Row(children: [Text('sss', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black),)],),
      const Row(children: [Text('sss', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 45, color: Colors.black),)],)
    ],);
  }
}
