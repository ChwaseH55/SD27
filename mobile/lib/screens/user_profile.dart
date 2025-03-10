import 'package:coffee_card/widgets/forumcreation_widget.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/creationformplus.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Fname + Lname',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body: SizedBox(
        height: height * 0.6,
        child: Column(
          children: [
             SizedBox(height: 20),
            // Image container
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(0.0),
                  image: DecorationImage(
                    image: NetworkImage('https://picsum.photos/id/237/200/300'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Add spacing between image and text

            // Text container
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
                child: Container(
                  height: 150, // Increase the height of the container
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text('Username: ', style: TextStyle(fontWeight: FontWeight.w900)),
                                Text('  Username Here '),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text('Email: ', style: TextStyle(fontWeight: FontWeight.w900)),
                                Text('  Users Email Here'),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text('Date Joined: ', style: TextStyle(fontWeight: FontWeight.w900)),
                                Text('  Date Joined Here'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}