import 'package:flutter/material.dart';

class ForumWidget extends StatelessWidget {
  final String forumName;
  final int forumNumber;

  const ForumWidget({
    super.key,
    required this.forumName,
    required this.forumNumber
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 8, bottom: 10),
        child: Column(
          children: <Widget>[
            
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Row(
                children: <Widget>[Text(forumName, style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 20
                      ),),],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 60,
                child: Container(
                  decoration:  BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: const BorderRadius.all(Radius.elliptical(100, 100)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Row(
                    
                      children: <Widget>[const Icon(
                          Icons.messenger_outline,
                        ),Text(forumNumber.toString())],
                    )
                  ),
                )
              )
            ),
          ],
        ),
      ),
    );
  }
}
