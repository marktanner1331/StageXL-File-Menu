import 'package:stagexl/stagexl.dart';
import './MenuItem.dart';
import './HasMainMenuStyle.dart';
import './CanHaveChildMenuItems.dart';
import './FullWidthMenuItem.dart';
import './MenuItemGroup.dart';
import 'MainMenuStyle.dart';

class SimpleMenuItem extends Sprite
    with HasMainMenuStyle, CanHaveChildMenuItems, FullWidthMenuItem
    implements MenuItem {
  TextField _label;
  MenuItemGroup _parentGroup;

  SimpleMenuItem(
      MainMenuStyle style, MenuItemGroup parentGroup, String text) {
    this.style = style;
    this.menuItems.style = style;
    this._parentGroup = parentGroup;

    _label = TextField()
      ..text = text
      ..x = 8
      ..y = 5
      ..autoSize = TextFieldAutoSize.LEFT
      ..mouseEnabled = false;

    this.addChild(_label);

    this.mouseCursor = MouseCursor.POINTER;

    this.onMouseOver.listen(onHadMouseOver);
    this.onMouseOut.listen(onHadMouseOut);
    this.onAddedToStage.listen((Event e) {
      redrawBG(style.menuItemBackColor);
      _label.textColor = style.menuItemTextColor;
    });

    //we need to redraw the BG at least once, just so we have some dimensions
    relayout();
    redrawBG(style.menuItemBackColor);
  }

  void relayout() {
    _label.defaultTextFormat.size = style.menuItemTextSize;

    _label.width = _label.textWidth;
    _label.height = _label.textHeight;

    redrawBG(style.menuItemBackColor);

    menuItems.relayout();
  }

  void onHadMouseOver(MouseEvent e) {
    redrawBG(style.menuItemHighlightColor);
    _parentGroup.closeOpenMenuItems();
    open();
  }

  void onHadMouseOut(MouseEvent e) {
    redrawBG(style.menuItemBackColor);
  }

  void redrawBG(int color) {
    graphics.clear();
    graphics.rect(0, 0, preferredWidth, _label.textHeight + 12);
    graphics.fillColor(color);
  }

  @override
  num get minWidth => _label.textWidth + 16;

  @override
  void close() {
    super.close();
    menuItems.closeOpenMenuItems();
    stage.removeChild(menuItems);
  }

  @override
  void open() {
    super.open();
    Point p = Point(preferredWidth, 0);
    p = localToGlobal(p);

    menuItems
      ..x = p.x
      ..y = p.y;
    stage.addChild(menuItems);
  }
}