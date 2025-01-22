import 'package:flutter/material.dart';

class PostinfoWidget extends StatelessWidget {
  final String? username;
  final String? posttitle;
  final String? postContent;

  const PostinfoWidget({
    super.key,
    required this.username,
    required this.posttitle,
    required this.postContent,
  });

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: height * 0.3,
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Column( // Removed const here
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, top: 6),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        username!,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        posttitle!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(postContent!, style: const TextStyle(
                          fontSize: 28,
                        )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
