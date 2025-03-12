import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:coffee_card/api_request/auth_request.dart';
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
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: Text(
                  'UCF',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.forum_rounded,
                ),
                title: const Text('Disscussions'),
                onTap: () {
                  Navigator.pushNamed(context, '/pos');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.announcement,
                ),
                title: const Text('Announcements'),
                onTap: () {
                  Navigator.pushNamed(context, '/annc');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.train,
                ),
                title: const Text('Scores'),
                onTap: () {
                  Navigator.pushNamed(context, '/scores');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.list_alt,
                ),
                title: const Text('Events'),
                onTap: () {
                  Navigator.pushNamed(context, '/events');
                },
              ),
              Visibility(
                visible: true,
                child: ListTile(
                  leading: const Icon(
                    Icons.train,
                  ),
                  title: const Text('User'),
                  onTap: () {
                    Navigator.pushNamed(context, '/users');
                  },
                )
              ),
            ],
          ),
        ),
        body: const HomePage());
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
