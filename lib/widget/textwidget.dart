import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({super.key, required this.topic, required this.content});

  final String topic, content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          topic,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
          textAlign: TextAlign.center,
        ),
        Text(
          content,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
