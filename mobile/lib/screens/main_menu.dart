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
            Icon(icon, size: 48, color: const Color.fromRGBO(186, 155, 55, 1)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 5),
            // Golf Logo
            SizedBox(
              height: height * 0.4,
              width: width * 0.7,
              child: const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/golf_logo.jpg'),
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to the UCF Golf App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(6),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
                shrinkWrap: true, // Important!
                physics:
                    NeverScrollableScrollPhysics(), // Prevent inner scrolling
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
                  GridTile(
                      icon: Icons.forum_rounded,
                      title: "Chat",
                      onTap: () {
                        Navigator.pushNamed(context, '/chat');
                      }),
                ],
              ),
            ),

            // Optional: Add more widgets below if needed

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
