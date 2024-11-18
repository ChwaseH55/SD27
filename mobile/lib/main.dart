import 'package:coffee_card/screens/login_screen.dart';
import 'package:coffee_card/screens/main_menu.dart';
import 'package:coffee_card/screens/discussionforum_screen.dart';
import 'package:coffee_card/screens/forumpost_screen.dart';
import 'package:coffee_card/screens/announcement_list.dart';
import 'package:coffee_card/screens/tournament_list.dart';
import 'package:coffee_card/screens/register_screen.dart';
import 'package:coffee_card/screens/announcement_creation.dart';
import 'package:coffee_card/screens/announcementdetail_screen.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() => runApp(MaterialApp(
   title: 'Named Routes Demo',
   
  // Start the app with the "/" named route. In this case, the app starts
  // on the LoginScreen widget.
  initialRoute: '/mainMenu',
  routes: {
    // When navigating to the "/" route, build the FirstScreen widget.
    '/': (context) => const LoginScreen(),
    '/reg': (context) => const RegisterScreen(),
    '/mainMenu': (context) => const MainMenu(),
    '/dis': (context) => const DiscussionForum(),
    '/pos': (context) => const ForumpostScreen(),
    '/tou': (context) => const TournamentList(),
    '/annc': (context) => const AnnouncementList(),
    '/anncCrea': (context) => const AnnouncementCreationScreen(),
    '/anncDetail': (context) => const AnnouncementdetailScreen(),
  }
));