import 'package:coffee_card/widgets/forumcreation_widget.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/widgets/creationformplus.dart';

class CreateForum extends StatelessWidget {

  const CreateForum({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forum Creation',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(186, 155, 55, 1),
      ),
      body:  Padding(
        padding: const EdgeInsets.only(top:20),
        child: SizedBox( height: height*0.4, child:  const ForumCreationWidget())
      ),
    );
  }
}

