import 'package:flutter/material.dart';

class FormAddWidget extends StatelessWidget {
  const FormAddWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const DisplayCreation();
  }
}

class DisplayCreation extends StatefulWidget {
  const DisplayCreation({super.key});

  @override
  State<DisplayCreation> createState() => _DisplayCreationState();
}

class _DisplayCreationState extends State<DisplayCreation> {
  bool _isVisible = false; // State to track visibility

  void _toggleWidgetVisibility() {
    setState(() {
      _isVisible = !_isVisible; // Toggle the visibility state
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _toggleWidgetVisibility();
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
