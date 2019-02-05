import 'package:stagexl/stagexl.dart';
import './FullWidthMenuItem.dart';
import './HasMainMenuStyle.dart';
import 'dart:math';
import './CanHaveChildMenuItems.dart';

class MenuItemGroup extends Sprite with HasMainMenuStyle {
  List<FullWidthMenuItem> _menuItems;

  MenuItemGroup() {
    _menuItems = List<FullWidthMenuItem>();
  }

  void relayout() {
    num deltaY = 7;

    if (_menuItems.length > 0) {
      for (FullWidthMenuItem menuItem in _menuItems) {
        menuItem.relayout();
        menuItem.y = deltaY;
        deltaY += menuItem.height;
      }

      num tempWidth = this.minWidth;
      for (FullWidthMenuItem menuItem in _menuItems) {
        menuItem.preferredWidth = tempWidth;
      }

      _redrawBG(tempWidth, deltaY + 7);
    }
  }

  void addMenuItem(FullWidthMenuItem menuItem) {
    graphics.clear();

    menuItem.y = max(this.height, 7);

    _menuItems.add(menuItem);
    addChild(menuItem);

    num tempWidth = this.minWidth;
    for (FullWidthMenuItem menuItem in _menuItems) {
      menuItem.preferredWidth = tempWidth;
    }

    _redrawBG(tempWidth, menuItem.y + menuItem.height + 7);
  }

  void _redrawBG(num _width, num _height) {
    graphics.clear();
    graphics.rect(0, 0, _width, _height);
    graphics.fillColor(style.menuItemBackColor);
  }

  num get minWidth => _menuItems.map((x) => x.minWidth).reduce(max) + 50;

  void closeOpenMenuItems() {
    for (FullWidthMenuItem menuItem in _menuItems) {
      if (menuItem is CanHaveChildMenuItems) {
        CanHaveChildMenuItems canHaveChildMenuItems =
            (menuItem as CanHaveChildMenuItems);
        if (canHaveChildMenuItems.isOpen) {
          canHaveChildMenuItems.close();
        }
      }
    }
  }
}