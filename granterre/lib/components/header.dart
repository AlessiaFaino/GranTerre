import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {

  final bool big;
  final String text;

  const AppHeader({
    super.key,
    required this.big,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: big ? 20 : 18,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.justify,
    );
  }
}