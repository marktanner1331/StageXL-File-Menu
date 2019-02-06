import 'package:stagexl/stagexl.dart';
import 'dart:math';
import './MainMenuStyle.dart';
import './MenuButton.dart';
import './CanHaveChildMenuItems.dart';
import './MenuItem.dart';

class MainMenu extends DisplayObjectContainer with MainMenuStyle {
  Sprite _background;
  List<MenuButton> _menuItems;
  EventStreamSubscription<MouseEvent> _stageClickSubscription;

  bool _hasOpenItem = false;

  MainMenu() {
    _background = new Sprite();
    this.addChild(_background);

    _menuItems = List<MenuButton>();

    _redrawBG();
  }

  @override
  set menuButtonBackColor(int value) {
    super.menuButtonBackColor = value;
    _relayout();
  }

  @override
  set menuButtonTextColor(int value) {
    super.menuButtonTextColor = value;
    _relayout();
  }

  @override
  set fileMenuBackColor(int value) {
    super.fileMenuBackColor = value;
    _redrawBG();
  }

  @override
  set menuItemTextSize(int value) {
    super.menuItemTextSize = value;
    _relayout();
  }

  @override
  set menuButtonTextSize(int value) {
    super.menuButtonTextSize = value;
    _relayout();
  }

  void _relayout() {
    num deltaX = 0;
    for (MenuButton fileButton in _menuItems) {
      fileButton.relayout();
      fileButton.x = deltaX;
      deltaX += fileButton.width;
    }

    _redrawBG();
  }

  void _onMenuItemMouseOver(MouseEvent e) {
    if (_hasOpenItem == false) {
      return;
    }

    _closeOpenItem();

    CanHaveChildMenuItems menuItem = e.currentTarget as CanHaveChildMenuItems;
    menuItem.open();
    _hasOpenItem = true;
  }

  void _onMenuItemClick(MouseEvent e) {
    CanHaveChildMenuItems menuItem = e.currentTarget as CanHaveChildMenuItems;

    if (menuItem.isOpen) {
      return;
    }

    menuItem.open();
    _hasOpenItem = true;
    this._stageClickSubscription = stage.onMouseClick.listen(_onStageClick);
    e.stopPropagation();
  }

  MenuItem addMenuItem(String text) {
    MenuButton menuItem = MenuButton(this, text);

    menuItem.onMouseClick.listen(_onMenuItemClick);
    menuItem.onMouseOver.listen(_onMenuItemMouseOver);

    if (_menuItems.isNotEmpty) {
      DisplayObject lastItem = _menuItems.last;
      num right = lastItem.x + lastItem.width;
      menuItem.x = right;
    }

    _menuItems.add(menuItem);
    this.addChild(menuItem);

    if (menuItem.height > _background.height) {
      _redrawBG();
    }

    return menuItem;
  }

  void _onStageClick(MouseEvent e) {
    _closeOpenItem();
    _stageClickSubscription.cancel();
  }

  void _closeOpenItem() {
    for (CanHaveChildMenuItems item in _menuItems) {
      if (item.isOpen) {
        item.close();
      }
    }

    _hasOpenItem = false;
  }

  void _redrawBG() {
    _background.graphics.clear();

    if (_menuItems.isNotEmpty) {
      num height = _menuItems.map((x) => x.height).reduce(max);

      _background.graphics.rect(0, 0, 100, height);
    } else {
      _background.graphics.rect(0, 0, 100, 1);
    }

    _background.graphics.fillColor(fileMenuBackColor);
  }

  @override
  num get width {
    return _background.width;
  }

  @override
  set width(num value) {
    _background.width = value;
  }
}
