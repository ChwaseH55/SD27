import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/notifications.dart';
import 'package:coffee_card/arguments/regOrAllargument.dart';
import 'package:coffee_card/screens/listofevents_screen.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'UCF Golf Club',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.account_circle_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/pro');
              },
            )
          ],
        ),
        body: const HomePage());
  }
}

class GridTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const GridTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keeps the content centered
          children: <Widget>[
            // Golf Logo
            SizedBox(
              height: height * 0.3,
              width: width * 0.6,
              child: const Image(
                image: AssetImage('assets/images/golf_logo.jpg'),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20), // Spacing between image and text
            const Text(
              'Welcome to the UCF Golf App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: GridView.count(
                  crossAxisCount: 3, // Adjust the number of columns
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                  children: [
                    GridTile(
                        icon: Icons.forum_rounded,
                        title: "Discussions",
                        onTap: () {
                          Navigator.pushNamed(context, '/pos');
                        }),
                    GridTile(
                        icon: Icons.announcement,
                        title: "Announcements",
                        onTap: () {
                          Navigator.pushNamed(context, '/annc');
                        }),
                    GridTile(
                        icon: Icons.score,
                        title: "Scores",
                        onTap: () {
                          Navigator.pushNamed(context, '/scores');
                        }),
                    GridTile(
                        icon: Icons.list_alt,
                        title: "Events",
                        onTap: () async {
                          await Navigator.pushNamed(
                              context, EventsListScreen.routeName,
                              arguments: IsAllOrReg(true));
                        }),
                    GridTile(
                        icon: Icons.people,
                        title: "Users",
                        onTap: () {
                          Navigator.pushNamed(context, '/users');
                        }),
                        GridTile(
                        icon: Icons.nature_people,
                        title: "Score Approval",
                        onTap: () {
                          Navigator.pushNamed(context, '/adminscores');
                        }),
                  ],
                ),
              ),
            ),

            // CarouselSlider(
            //   items: [
            //     Container(
            //       margin: const EdgeInsets.all(6.0),
            //       child: const Text('Message'),
            //     ),
            //     //1st Image of Slider
            //     Container(
            //       margin: const EdgeInsets.all(6.0),
            //       child: const Text('Message'),
            //     ),
            //   ],

            //   //Slider Container properties
            //   options: CarouselOptions(
            //     height: 180.0,
            //     enlargeCenterPage: true,
            //     autoPlay: true,
            //     aspectRatio: 16 / 9,
            //     autoPlayCurve: Curves.fastOutSlowIn,
            //     enableInfiniteScroll: true,
            //     autoPlayAnimationDuration: const Duration(milliseconds: 800),
            //     viewportFraction: 0.8,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
