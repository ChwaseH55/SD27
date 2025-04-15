import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:coffee_card/api_request/auth_request.dart';
import 'package:coffee_card/api_request/notifications.dart';
import 'package:coffee_card/arguments/regOrAllargument.dart';
import 'package:coffee_card/screens/adminscorereview_screen.dart';
import 'package:coffee_card/screens/announcement_list.dart';
import 'package:coffee_card/screens/chat_screen.dart';
import 'package:coffee_card/screens/listofevents_screen.dart';
import 'package:coffee_card/screens/listofpostsinforum_screen.dart';
import 'package:coffee_card/screens/scores_screen.dart';
import 'package:coffee_card/screens/users_list.dart';
import 'package:coffee_card/widgets/appBar_widget.dart';
import 'package:coffee_card/widgets/slideRightTransition.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(title: 'UCF Main', showBackButton: false,),
        body:  HomePage());
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

    return Stack(
      children: [
        // Decorative background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color.fromARGB(255, 240, 235, 220)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Positioned circles for decoration
        Positioned(
          top: -50,
          left: -30,
          child: _buildCircle(100, Colors.amber.withOpacity(0.2)),
        ),
        Positioned(
          bottom: -50,
          right: -20,
          child: _buildCircle(140, Colors.amber.withOpacity(0.3)),
        ),
        Positioned(
          bottom: 40,
          right: -40,
          child: _buildCircle(140, Colors.amber.withOpacity(0.3)),
        ),

        // Content
        SingleChildScrollView(
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
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      GridTile(
                          icon: Icons.forum_rounded,
                          title: "Discussions",
                          onTap: () {
                            Navigator.push(context,
                                slideRightRoute(const ForumpostScreen()));
                          }),
                      GridTile(
                          icon: Icons.announcement,
                          title: "Announcements",
                          onTap: () {
                            Navigator.push(
                                context,
                                slideRightRoute(
                                    const AnnouncementListScreen()));
                          }),
                      GridTile(
                          icon: Icons.score,
                          title: "Scores",
                          onTap: () {
                            Navigator.push(context,
                                slideRightRoute(const GolfScoreScreen()));
                          }),
                      GridTile(
                          icon: Icons.list_alt,
                          title: "Events",
                          onTap: () {
                            Navigator.push(
                              context,
                              slideRightRoute(const EventsListScreen(
                                  isAllEvents:
                                      true)), // replace with your constructor
                            );
                          }),
                      GridTile(
                          icon: Icons.people,
                          title: "Users",
                          onTap: () {
                            Navigator.push(
                                context, slideRightRoute(const UserList()));
                          }),
                      GridTile(
                          icon: Icons.nature_people,
                          title: "Score Approval",
                          onTap: () {
                            Navigator.push(context,
                                slideRightRoute(const ScoreListScreen()));
                          }),
                      GridTile(
                          icon: Icons.forum_rounded,
                          title: "Chat",
                          onTap: () {
                            Navigator.push(
                                context, slideRightRoute(const ChatDisplay()));
                          }),
                          GridTile(
                        icon: Icons.shopping_cart,
                        title: "Shop",
                        onTap: () {
                          Navigator.pushNamed(context, '/shop');
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Circle decoration helper
  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
