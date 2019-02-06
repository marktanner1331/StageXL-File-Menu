import 'package:stagexl/stagexl.dart';
import './HasMainMenuStyle.dart';
import './CanHaveChildMenuItems.dart';
import './MenuItem.dart';
import './MainMenuStyle.dart';

class MenuButton extends Sprite
    with HasMainMenuStyle, CanHaveChildMenuItems
    implements MenuItem {
  TextField _label;

  MenuButton(MainMenuStyle style, String text) {
    this.style = style;
    menuItems.style = style;

    _label = TextField()
      ..text = text
      ..x = 8
      ..y = 5
      ..mouseEnabled = false;

    this.addChild(_label);

    this.mouseCursor = MouseCursor.POINTER;

    this
        .onMouseOver
        .listen((Event e) => redrawBG(style.menuButtonHighlightColor));
    this.onMouseOut.listen((Event e) => redrawBG(style.menuButtonBackColor));

    //we need to redraw the BG at least once, just so we have some dimensions
    relayout();
    redrawBG(style.menuButtonBackColor);
  }

  void relayout() {
    _label.defaultTextFormat.size = style.menuButtonTextSize;

    _label.width = _label.textWidth;
    _label.height = _label.textHeight;
    _label.textColor = style.menuButtonTextColor;

    redrawBG(style.menuButtonBackColor);

    menuItems.relayout();
  }

  void redrawBG(int color) {
    graphics.clear();
    graphics.rect(0, 0, _label.textWidth + 16, _label.textHeight + 10);
    graphics.fillColor(color);
  }

  @override
  void close() {
    super.close();
    menuItems.closeOpenMenuItems();
    stage.removeChild(menuItems);
  }

  @override
  void open() {
    super.open();
    menuItems
      ..x = x
      ..y = height;
    stage.addChild(menuItems);
  }
}
