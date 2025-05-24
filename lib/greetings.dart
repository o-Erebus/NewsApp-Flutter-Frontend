import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Greetings extends StatelessWidget {
  const Greetings({super.key});
  String getGreetings() {
    var time = DateTime.now().hour;
    if (time < 12) {
      return "Good Morning";
    } else if (time < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = getGreetings();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        greeting,
        style: TextStyle(
          fontSize: 22, // Prominent heading size
          fontWeight: FontWeight.bold,
          color:
              Theme.of(context).textTheme.titleLarge?.color ?? Colors.black87,
        ),
      ),
    );
  }
}
