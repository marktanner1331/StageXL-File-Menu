import 'dart:async';

import 'package:stagexl/stagexl.dart';
import './HasMainMenuStyle.dart';
import './CanHaveChildMenuItems.dart';

abstract class MenuItem with HasMainMenuStyle, CanHaveChildMenuItems {
  EventStream<MouseEvent> get onMouseClick =>
      InteractiveObject.mouseClickEvent.forTarget(this as DisplayObject);

  bool hasEventListener(String eventType, {bool useCapture = false});
  StreamSubscription<T> addEventListener<T extends Event>(
      String eventType, EventListener<T> eventListener,
      {bool useCapture = false, int priority = 0});
  void removeEventListener<T extends Event>(
      String eventType, EventListener<T> eventListener,
      {bool useCapture = false});
  void removeEventListeners(String eventType);
}
