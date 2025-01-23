import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final String postName;
  
  final int likeNumber;

  const PostWidget(
      {super.key,
      required this.postName,
      
      required this.likeNumber});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 5, right: 5),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 8, bottom: 10),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: Row(
                    children: <Widget>[
                      Text(
                        postName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Row(children: <Widget>[
                      SizedBox(
                          width: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.black, width: 2),
                              borderRadius: const BorderRadius.all(
                                  Radius.elliptical(90, 100)),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.thumb_up_alt,
                                    ),
                                    Text(likeNumber.toString())
                                  ],
                                )),
                          ))
                    ])),
              ],
            ),
          ),
        ));
  }
}
