import 'package:coffee_card/providers/announcement_info_provider.dart';
import 'package:coffee_card/providers/announcement_provider.dart';
import 'package:coffee_card/providers/events_info_provider.dart';
import 'package:coffee_card/providers/events_provider.dart';
import 'package:coffee_card/providers/forum_info_provider.dart';
import 'package:coffee_card/providers/forum_provider.dart';
import 'package:coffee_card/providers/forum_reply_provider.dart';
import 'package:coffee_card/providers/scores_provider.dart';
import 'package:coffee_card/providers/shop_provider.dart';
import 'package:coffee_card/providers/user_provider.dart';
import 'package:coffee_card/screens/adminscorereview_screen.dart';
import 'package:coffee_card/screens/calendar_screen.dart';
import 'package:coffee_card/screens/eventCreation.dart';
import 'package:coffee_card/screens/login_screen.dart';
import 'package:coffee_card/screens/main_menu.dart';
import 'package:coffee_card/screens/shop_screen.dart';
import 'package:coffee_card/screens/listofpostsinforum_screen.dart';
import 'package:coffee_card/screens/announcement_list.dart';
import 'package:coffee_card/screens/scores_screen.dart';
import 'package:coffee_card/screens/register_screen.dart';
import 'package:coffee_card/screens/announcement_creation.dart';
import 'package:coffee_card/screens/forumcreation_screen.dart';
import 'package:coffee_card/screens/userprofile_screen.dart';
import 'package:coffee_card/screens/users_list.dart';
import 'package:coffee_card/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/chat_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'SD27',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await Notifications.intsance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ForumProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()..fetchEvents()),
        ChangeNotifierProvider(create: (_) => EventsInfoProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ReplyProvider()),
        ChangeNotifierProvider(create: (_) => ScoresProvider()),
        ChangeNotifierProvider(
            create: (_) => AnnouncementProvider()..fetchAnnouncements()),
        ChangeNotifierProvider(create: (_) => AnnouncementInfoProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) => ShopProvider(context.read<UserProvider>()),
        ),
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
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 240, 239, 239)),
      navigatorObservers: [routeObserver],
      title: 'UCF Golf Club',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/reg': (context) => const RegisterScreen(),
        '/mainMenu': (context) => const MainMenu(),
        '/createFor': (context) => const CreateForum(),
        '/pos': (context) => const ForumpostScreen(),
        '/annc': (context) => const AnnouncementListScreen(),
        '/shop': (context) => const ShopScreen(),
        '/pro': (context) => const UserProfileScreen(),
        '/calendar': (context) => const TableEventsExample(),
        '/createEvent': (context) => const CreateEvent(),
        '/scores': (context) => const GolfScoreScreen(),
        '/users': (context) => const UserList(),
        '/adminscores': (context) => const ScoreListScreen(),
        '/chat': (context) => const ChatDisplay(),
        //PostCreationForm.routeName: (context) => const PostCreationForm(),
        CreateEvent.routeName: (context) => const CreateEvent(),
        AnnouncementCreationScreen.routeName: (context) =>
            const AnnouncementCreationScreen(),
      },
    );
  }
}
