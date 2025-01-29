import 'package:coffee_card/screens/calendar_screen.dart';
import 'package:coffee_card/screens/login_screen.dart';
import 'package:coffee_card/screens/main_menu.dart';
import 'package:coffee_card/screens/listofforums_screen.dart';
import 'package:coffee_card/screens/listofpostsinforum_screen.dart';
import 'package:coffee_card/screens/announcement_list.dart';
import 'package:coffee_card/screens/tournament_list.dart';
import 'package:coffee_card/screens/register_screen.dart';
import 'package:coffee_card/screens/announcement_creation.dart';
import 'package:coffee_card/screens/announcementdetail_screen.dart';
import 'package:coffee_card/screens/forumcreation_screen.dart';
import 'package:coffee_card/screens/disscusisonpost_info.dart';
import 'package:coffee_card/screens/userprofile_screen.dart';
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
    '/createFor': (context) => const CreateForum(),
    '/pos': (context) => const ForumpostScreen(),
    '/tou': (context) => const TournamentList(),
    '/annc': (context) => const AnnouncementList(),
    '/anncCrea': (context) => const AnnouncementCreationScreen(),
    '/anncDetail': (context) => const AnnouncementdetailScreen(),
    '/tes': (context) => const DisscusisonpostInfoScreen(),
    '/pro': (context) => const UserProfileScreen(),
    '/calendar': (context) => const TableBasicsExample(),
    PostsScreenInfo.routeName: (context) =>
        const PostsScreenInfo(),
  }
));