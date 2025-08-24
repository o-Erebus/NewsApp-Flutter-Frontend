import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int _previousIndex = 0;

  int get selectedIndex => _selectedIndex;
  int get previousIndex => _previousIndex;

  // Normal navigation (tracks history by default)
  void setSelectedIndex(int index, {bool trackHistory = true}) {
    if (index == _selectedIndex) return;
    if (trackHistory) {
      _previousIndex = _selectedIndex;
    }
    _selectedIndex = index;
    notifyListeners();
  }

  // Restore selection WITHOUT changing history
  // This method is corrected to always notify listeners, forcing a UI refresh.
  void restoreTo(int index) {
    // The original check 'if (index == _selectedIndex) return;' was removed.
    // This ensures that even if the state value is the same, the UI is
    // notified to rebuild. This is crucial for correcting visual glitches
    // where a widget's internal state is out of sync with the app's state.
    _selectedIndex = index;
    notifyListeners();
  }

  // Only use if you truly need swap-back behavior elsewhere
  void goBack() {
    if (_previousIndex == _selectedIndex) return;
    final temp = _selectedIndex;
    _selectedIndex = _previousIndex;
    _previousIndex = temp;
    notifyListeners();
  }
}
