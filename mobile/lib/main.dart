import 'package:coffee_card/screens/login_screen.dart';
import 'package:coffee_card/screens/main_menu.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
   title: 'Named Routes Demo',
  // Start the app with the "/" named route. In this case, the app starts
  // on the LoginScreen widget.
  initialRoute: '/',
  routes: {
    // When navigating to the "/" route, build the FirstScreen widget.
    '/': (context) => const LoginScreen(),
    '/mainMenu': (context) => const MainMenu()
  }
));