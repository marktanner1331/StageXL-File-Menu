import 'dart:async';

import 'package:stagexl/stagexl.dart';

abstract class CheckboxMenuItem {
  static const String IS_CHECKED_CHANGED = "IS_CHECKED_CHANGED";

  ///A boolean that tracked whether the menu item is checked.
  ///Setting this value programatically will raise the onIsCheckedChanged event.
  bool isChecked;

  ///An event that fires every time the isChecked property changes.
  EventStream<Event> get onIsCheckedChanged;

  bool hasEventListener(String eventType, {bool useCapture = false});
  StreamSubscription<T> addEventListener<T extends Event>(
      String eventType, EventListener<T> eventListener,
      {bool useCapture = false, int priority = 0});
  void removeEventListener<T extends Event>(
      String eventType, EventListener<T> eventListener,
      {bool useCapture = false});
  void removeEventListeners(String eventType);
}
