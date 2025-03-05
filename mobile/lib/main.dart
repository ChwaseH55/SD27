import 'package:coffee_card/providers/announcement_info_provider.dart';
import 'package:coffee_card/providers/announcement_provider.dart';
import 'package:coffee_card/providers/events_info_provider.dart';
import 'package:coffee_card/providers/events_provider.dart';
import 'package:coffee_card/providers/forum_info_provider.dart';
import 'package:coffee_card/providers/forum_provider.dart';
import 'package:coffee_card/screens/announcement_info.dart';
import 'package:coffee_card/screens/calendar_screen.dart';
import 'package:coffee_card/screens/eventCreation.dart';
import 'package:coffee_card/screens/event_info.dart';
import 'package:coffee_card/screens/login_screen.dart';
import 'package:coffee_card/screens/main_menu.dart';
import 'package:coffee_card/screens/listofforums_screen.dart';
import 'package:coffee_card/screens/listofpostsinforum_screen.dart';
import 'package:coffee_card/screens/announcement_list.dart';
import 'package:coffee_card/screens/postcreation_screen.dart';
import 'package:coffee_card/screens/scores_screen.dart';
import 'package:coffee_card/screens/tournament_list.dart';
import 'package:coffee_card/screens/register_screen.dart';
import 'package:coffee_card/screens/announcement_creation.dart';
import 'package:coffee_card/screens/announcementdetail_screen.dart';
import 'package:coffee_card/screens/forumcreation_screen.dart';
import 'package:coffee_card/screens/disscusisonpost_info.dart';
import 'package:coffee_card/screens/listofevents_screen.dart';
import 'package:coffee_card/screens/userprofile_screen.dart';
import 'package:coffee_card/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ForumProvider()..fetchPosts()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()..fetchEvents()),
        ChangeNotifierProvider(create: (_) => EventsInfoProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()..fetchAnnouncements()),
        ChangeNotifierProvider(create: (_) => AnnouncementInfoProvider()),
        // Add more providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Named Routes Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/reg': (context) => const RegisterScreen(),
        '/mainMenu': (context) => const MainMenu(),
        '/dis': (context) => const DiscussionForum(),
        '/createFor': (context) => const CreateForum(),
        '/pos': (context) => const ForumpostScreen(),
        '/tou': (context) => const TournamentList(),
        '/annc': (context) => const AnnouncementListScreen(),
        '/anncDetail': (context) => const AnnouncementdetailScreen(),
        '/tes': (context) => const DisscusisonpostInfoScreen(),
        '/pro': (context) => const UserProfileScreen(),
        '/calendar': (context) => const TableEventsExample(),
        '/events': (context) => const EventsListScreen(),
        '/createEvent': (context) => const CreateEvent(),
        '/scores': (context) => const GolfScoreScreen(),

        PostsScreenInfo.routeName: (context) => const PostsScreenInfo(),
        EventInfo.routeName: (context) => const EventInfo(),
        PostCreationForm.routeName: (context) => const PostCreationForm(),
        CreateEvent.routeName: (context) => const CreateEvent(),
        AnnouncementInfo.routeName: (context) => const AnnouncementInfo(),
        AnnouncementCreationScreen.routeName: (context) => const AnnouncementCreationScreen(),
      },
    );
  }
}