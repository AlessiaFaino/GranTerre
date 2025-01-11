import 'package:flutter/material.dart';

class AppDescription extends StatelessWidget {

  final bool italic;
  final String text;
  final double maxWidth;

  const AppDescription({
    super.key,
    this.italic = false,
    this.maxWidth = 600,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {  
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

