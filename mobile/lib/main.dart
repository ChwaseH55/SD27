import 'package:coffee_card/screens/login_screen.dart';
import 'package:coffee_card/screens/main_menu.dart';
import 'package:coffee_card/screens/discussionforum_screen.dart';
import 'package:coffee_card/screens/forumpost_screen.dart';
import 'package:coffee_card/screens/announcement_list.dart';
import 'package:coffee_card/screens/tournament_list.dart';
import 'package:coffee_card/screens/register_screen.dart';
import 'package:coffee_card/screens/announcement_creation.dart';
import 'package:coffee_card/screens/announcementdetail_screen.dart';
import 'package:coffee_card/screens/shop_screen.dart';
import 'package:coffee_card/screens/user_profile.dart';
import 'package:coffee_card/screens/store_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() => runApp(
      ChangeNotifierProvider( // Wrap MaterialApp with ChangeNotifierProvider
        create: (context) => StoreState(),
        child: MyApp(), // MyApp is the widget containing MaterialApp
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Named Routes Demo',
      initialRoute: '/mainMenu',
      routes: {
        '/': (context) => const LoginScreen(),
        '/reg': (context) => const RegisterScreen(),
        '/mainMenu': (context) => const MainMenu(),
        '/dis': (context) => const DiscussionForum(),
        '/pos': (context) => const ForumpostScreen(),
        '/tou': (context) => const TournamentList(),
        '/annc': (context) => const AnnouncementList(),
        '/shop': (context) => ShopScreen(), // Corrected from ShopScreen()
        '/userpro': (context) => const UserProfile(),
        '/anncCrea': (context) => const AnnouncementCreationScreen(),
        '/anncDetail': (context) => const AnnouncementdetailScreen(),
      },
    );
  }
}