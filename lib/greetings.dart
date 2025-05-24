import 'package:flutter/cupertino.dart';

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
    return Text(greeting);
  }
}
