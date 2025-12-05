import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  bool _mode;
  bool get mode => _mode;
  ThemeNotifier({bool mode = true}) : _mode = mode;

  void toggleMode() {
    _mode = _mode == false ? true: false;
    notifyListeners();
  }
}