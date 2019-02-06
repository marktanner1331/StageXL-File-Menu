import 'package:stagexl/stagexl.dart';
import './FullWidthMenuItem.dart';
import './HasMainMenuStyle.dart';
import './MenuItemGroup.dart';
import './MainMenuStyle.dart';

class Seperator extends Sprite with FullWidthMenuItem, HasMainMenuStyle {
  MenuItemGroup _parentGroup;

  Seperator(MainMenuStyle style, MenuItemGroup parentGroup) {
    this.style = style;
    this._parentGroup = parentGroup;

    this
        .onMouseOver
        .listen((MouseEvent e) => _parentGroup.closeOpenMenuItems());

    this.onAddedToStage.listen((Event e) {
      redrawBG(style.menuItemBackColor);
    });

    //we need to redraw the BG at least once, just so we have some dimensions
    relayout();
    redrawBG(style.menuItemBackColor);
  }

  void relayout() {
    redrawBG(style.menuItemBackColor);
  }

  @override
  num get minWidth => 1;

  void redrawBG(int color) {
    graphics.clear();

    graphics.beginPath();
    graphics.rect(0, 0, preferredWidth, 15);
    graphics.fillColor(color);
    graphics.closePath();

    graphics.beginPath();
    graphics.rect(7, 7, preferredWidth - 14, 2);
    graphics.fillColor(style?.seperatorColor ?? 0xff000000);
    graphics.closePath();
  }
}
