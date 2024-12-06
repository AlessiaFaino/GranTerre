import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {

  final String text;

  const AppTitle({
    super.key,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.teal,
        fontSize: 40,
      ),
    );
  }
}