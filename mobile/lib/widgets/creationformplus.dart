import 'package:flutter/material.dart';

class FormAddWidget extends StatelessWidget {
  const FormAddWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // handle button press
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color:  Color.fromRGBO(186, 155, 55, 1),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 42,
        ),
      ),
    );
  }
}
