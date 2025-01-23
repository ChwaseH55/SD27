import 'package:flutter/material.dart';

class ReplyWidget extends StatelessWidget {
  final String userName;
  final String? createDate;
  final String? content;
  final int likeNumber;

  const ReplyWidget(
      {super.key,
      required this.userName,
      required this.createDate,
      required this.content,
      required this.likeNumber});

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/anncDetail');
        },
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black),
              bottom: BorderSide(color: Colors.black),
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 8, bottom: 10, top: 5),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black
                        ),
                      )
                    ),
                    Text(createDate!)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: <Widget>[Text(content!)],
                  ),
                ),
                Row(children: <Widget>[
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
                ]),
              ],
            ),
          ),
        ));
  }
}
