import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? BackButton(
              color: Colors.black,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          : null,
      actions: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.account_circle_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/pro');
          },
        )
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(186, 155, 55, 1),
              Color.fromARGB(255, 240, 219, 130),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
