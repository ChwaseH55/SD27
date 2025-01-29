import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'UCF',
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
                  Icons.home,
                ),
                title: const Text('Disscussion Forum'),
                onTap: () {
                  Navigator.pushNamed(context, '/dis');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.train,
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
                title: const Text('Tournaments'),
                onTap: () {
                  Navigator.pushNamed(context, '/tou');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.train,
                ),
                title: const Text('calendar'),
                onTap: () {
                  Navigator.pushNamed(context, '/calendar');
                },
              )
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Login Btn
        CarouselSlider(
          items: [
            Container(
              margin: const EdgeInsets.all(6.0),
              decoration: const BoxDecoration(
                color: Colors.red,
              ),
            ),
            //1st Image of Slider
            Container(
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8.0),
                image: const DecorationImage(
                  image: AssetImage(
                      "assets/images/dog.jpg"), // Use your asset image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],

          //Slider Container properties
          options: CarouselOptions(
            height: 180.0,
            enlargeCenterPage: true,
            autoPlay: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.8,
          ),
        ),

    
      ],
    );
  }
}
