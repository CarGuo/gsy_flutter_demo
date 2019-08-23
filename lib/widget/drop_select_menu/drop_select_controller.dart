

import 'package:flutter/material.dart';

class DropSelectController extends ChangeNotifier {

  DropSelectEvent event;

  int menuIndex;

  int index;

  dynamic data;

  void hide() {
    event = DropSelectEvent.HIDE;
    notifyListeners();
  }

  void show(int index) {
    event = DropSelectEvent.ACTIVE;
    menuIndex = index;
    notifyListeners();
  }

  void select(dynamic data, {int index}) {
    event = DropSelectEvent.SELECT;
    this.data = data;
    this.index = index;
    notifyListeners();
  }
}


enum DropSelectEvent {
  SELECT,
  ACTIVE,
  HIDE,
}
