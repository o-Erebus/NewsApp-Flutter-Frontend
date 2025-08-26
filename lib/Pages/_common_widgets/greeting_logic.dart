// lib/Pages/_common_widgets/greeting_logic.dart
class GreetingLogic {
  static Map<String, String> getGreetingDataVariant1() {
    var hour = DateTime.now().hour;

    if (hour >= 0 && hour < 5) {
      return {'message': 'Rest well!', 'emoji': '😴'};
    } else if (hour >= 5 && hour < 8) {
      return {'message': 'Rise and shine!', 'emoji': '🌅'};
    } else if (hour >= 8 && hour < 12) {
      return {'message': 'Ready for the day?', 'emoji': '☕'};
    } else if (hour >= 12 && hour < 14) {
      return {'message': 'Enjoy your break!', 'emoji': '🍔'};
    } else if (hour >= 14 && hour < 17) {
      return {'message': 'Power through!', 'emoji': '💪'};
    } else if (hour >= 17 && hour < 20) {
      return {'message': 'Relax this evening!', 'emoji': '🛋️'};
    } else {
      return {'message': 'Sweet dreams!', 'emoji': '✨'};
    }
  }

  static Map<String, String> getGreetingDataVariant2() {
    var hour = DateTime.now().hour;

    if (hour < 12) {
      return {'greeting': 'Good Morning', 'emoji': '☀️'};
    } else if (hour < 17) {
      return {'greeting': 'Good Afternoon', 'emoji': '🌤️'};
    } else {
      return {'greeting': 'Good Evening', 'emoji': '🌙'};
    }
  }
}
