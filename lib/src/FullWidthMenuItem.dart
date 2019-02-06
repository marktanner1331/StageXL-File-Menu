import 'package:stagexl/stagexl.dart';

mixin FullWidthMenuItem on DisplayObject {
  num preferredWidth = 1;
  num get minWidth;
  void relayout();
}
