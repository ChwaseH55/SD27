import 'package:coffee_card/widgets/forumcreation_widget.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/creationformplus.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Your Account',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
        ),
        body: SizedBox(
          height: height*0.4,
          child: Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[Text('Name:', style: TextStyle(fontWeight: FontWeight.w900)), Text('asd')],
                                ),Row(
                                  children: <Widget>[Text('Email:'), Text('bfff')],
                                )
                              ],
                            )
                          )
                        ],
                      )))))
        );
  }
}
