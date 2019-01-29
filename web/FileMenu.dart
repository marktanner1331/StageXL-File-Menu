import 'package:stagexl/stagexl.dart';
import 'dart:math';

mixin FileMenuStyle {
  int fileMenuBackColor = 0xff000000;

  int menuButtonBackColor = 0xff000000;
  int menuButtonHighlightColor = 0xff333333;
  int menuButtonTextColor = 0xffffffff;

  int menuItemBackColor = 0xff000000;
  int menuItemHighlightColor = 0xff333333;
  int menuItemTextColor = 0xffffffff;

  int seperatorColor = 0xff333333;
}

mixin HasFileMenuStyle {
  FileMenuStyle style;
}

mixin HasStylableTextField {
  TextField get textField;

  int get textColor => textField.textColor;
  set textColor(int color) => textField.textColor = color;
}

mixin HasHighlightableBackground {
  int _backColor;
  int _highlightColor;

  set highlighted(bool value) {
    if (value) {
      redrawBG(_highlightColor);
    } else {
      redrawBG(_backColor);
    }
  }

  void redrawBG(int color);
}

mixin FullWidthMenuItem on DisplayObject {
  num preferredWidth = 1;
  num get minWidth;
}

mixin CanHaveChildMenuItems
    on HasStylableTextField, HasHighlightableBackground, DisplayObject {
  _MenuItemGroup _menuItems = _MenuItemGroup();

  SimpleMenuItem addMenuItem(String text) {
    SimpleMenuItem menuItem = SimpleMenuItem(_menuItems, text)
      .._backColor = _backColor
      .._highlightColor = _highlightColor
      ..textColor = textColor;

    _menuItems.addMenuItem(menuItem);
    return menuItem;
  }

  Seperator addSeperator() {
    Seperator menuItem = new Seperator(_menuItems).._backColor = _backColor;

    _menuItems.addMenuItem(menuItem);
    return menuItem;
  }

  CheckboxMenuItem addCheckboxMenuItem(String text, bool isChecked) {
    CheckboxMenuItem menuItem = CheckboxMenuItem(_menuItems, text, isChecked)
      .._backColor = _backColor
      .._highlightColor = _highlightColor
      ..textColor = textColor;

    _menuItems.addMenuItem(menuItem);
    return menuItem;
  }

  bool isOpen = false;
  void open() {
    isOpen = true;
  }

  void close() {
    isOpen = false;
  }
}

class FileButton extends Sprite
    with
        HasStylableTextField,
        HasHighlightableBackground,
        CanHaveChildMenuItems,
        HasFileMenuStyle {
  TextField _label;

  FileButton(String text) {
    _label = TextField()
      ..text = text
      ..x = 8
      ..y = 5
      ..mouseEnabled = false;

    _label
      ..width = _label.textWidth
      ..height = _label.textHeight;

    this.addChild(_label);

    this.mouseCursor = MouseCursor.POINTER;

    this.onMouseOver.listen((Event e) => highlighted = true);
    this.onMouseOut.listen((Event e) => highlighted = false);

    redrawBG(0xff000000);
  }

  @override
  TextField get textField => _label;

  @override
  void redrawBG(int color) {
    graphics.clear();
    graphics.rect(0, 0, _label.textWidth + 16, _label.textHeight + 10);
    graphics.fillColor(color);
  }

  @override
  void close() {
    super.close();
    _menuItems.closeOpenMenuItems();
    stage.removeChild(_menuItems);
  }

  @override
  void open() {
    super.open();
    _menuItems
      ..x = x
      ..y = height;
    stage.addChild(_menuItems);
  }
}

class _MenuItemGroup extends Sprite {
  List<FullWidthMenuItem> _menuItems;

  _MenuItemGroup() {
    _menuItems = List<FullWidthMenuItem>();
  }

  void addMenuItem(FullWidthMenuItem menuItem) {
    menuItem.y = this.height;

    _menuItems.add(menuItem);
    addChild(menuItem);

    num tempWidth = this.minWidth;
    for (FullWidthMenuItem menuItem in _menuItems) {
      menuItem.preferredWidth = tempWidth;
    }
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

class SimpleMenuItem extends Sprite
    with
        HasStylableTextField,
        HasHighlightableBackground,
        CanHaveChildMenuItems,
        FullWidthMenuItem,
        HasFileMenuStyle {
  TextField _label;
  _MenuItemGroup _parentGroup;

  SimpleMenuItem(_MenuItemGroup parentGroup, String text) {
    this._parentGroup = parentGroup;

    _label = TextField()
      ..text = text
      ..x = 8
      ..y = 5
      ..mouseEnabled = false;

    _label
      ..width = _label.textWidth
      ..height = _label.textHeight;

    this.addChild(_label);

    this.mouseCursor = MouseCursor.POINTER;

    this.onMouseOver.listen(onHadMouseOver);
    this.onMouseOut.listen(onHadMouseOut);

    redrawBG(0xff000000);
  }

  void onHadMouseOver(MouseEvent e) {
    highlighted = true;
    _parentGroup.closeOpenMenuItems();
    open();
  }

  void onHadMouseOut(MouseEvent e) {
    highlighted = false;
  }

  void redrawBG(int color) {
    graphics.clear();
    graphics.rect(0, 0, preferredWidth, _label.textHeight + 10);
    graphics.fillColor(color);
  }

  @override
  set preferredWidth(num value) {
    super.preferredWidth = value;
    redrawBG(_backColor);
  }

  @override
  num get minWidth => _label.textWidth + 16;

  @override
  void close() {
    super.close();
    _menuItems.closeOpenMenuItems();
    stage.removeChild(_menuItems);
  }

  @override
  void open() {
    super.open();
    Point p = Point(preferredWidth, 0);
    p = localToGlobal(p);

    _menuItems
      ..x = p.x
      ..y = p.y;
    stage.addChild(_menuItems);
  }

  @override
  TextField get textField => _label;
}

class CheckboxMenuItem extends Sprite
    with
        HasStylableTextField,
        HasHighlightableBackground,
        FullWidthMenuItem,
        HasFileMenuStyle {
  TextField _label;
  bool _isChecked;
  _MenuItemGroup _parentGroup;

  CheckboxMenuItem(_MenuItemGroup parentGroup, String text, bool isChecked) {
    this._parentGroup = parentGroup;
    this._isChecked = isChecked;

    _label = TextField()
      ..text = text
      ..x = 8
      ..y = 5
      ..mouseEnabled = false;

    _label
      ..x = _label.textHeight + 10
      ..width = _label.textWidth
      ..height = _label.textHeight;

    this.addChild(_label);

    this.mouseCursor = MouseCursor.POINTER;

    this.onMouseOver.listen(didMouseOver);
    this.onMouseOut.listen((MouseEvent e) => highlighted = false);
    this.onMouseClick.listen(didMouseClick);

    redrawBG(0xff000000);
  }

  void didMouseOver(MouseEvent e) {
    highlighted = true;
    _parentGroup.closeOpenMenuItems();
  }

  void didMouseClick(MouseEvent e) {
    _isChecked = !_isChecked;
    redrawBG(_backColor);
  }

  void redrawBG(int color) {
    graphics.clear();

    num tempHeight = _label.textHeight + 10;

    graphics.beginPath();
    graphics.rect(0, 0, preferredWidth, _label.textHeight + 10);
    graphics.fillColor(color);
    graphics.closePath();

    graphics.beginPath();
    graphics.rect(7, 7, tempHeight - 14, tempHeight - 14);

    if (_isChecked) {
      graphics.moveTo(9, tempHeight / 2);
      graphics.lineTo(7 + (tempHeight - 14) / 3, tempHeight - 9);
      graphics.lineTo(tempHeight - 9, 9);
    }

    graphics.strokeColor(_label.textColor);
    graphics.closePath();
  }

  @override
  set preferredWidth(num value) {
    super.preferredWidth = value;
    redrawBG(_backColor);
  }

  @override
  num get minWidth => _label.x + _label.textWidth + 16;

  @override
  TextField get textField => _label;
}

class Seperator extends Sprite with FullWidthMenuItem, HasFileMenuStyle {
  int _backColor = 0xff000000;
  _MenuItemGroup _parentGroup;

  Seperator(_MenuItemGroup parentGroup) {
    this._parentGroup = parentGroup;
    this
        .onMouseOver
        .listen((MouseEvent e) => _parentGroup.closeOpenMenuItems());

    redrawBG(0xff000000);
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
    graphics.rect(0, 7, preferredWidth, 2);
    graphics.fillColor(0xff333333);
    graphics.closePath();
  }

  @override
  set preferredWidth(num value) {
    super.preferredWidth = value;
    redrawBG(_backColor);
  }
}

class FileMenu extends DisplayObjectContainer with FileMenuStyle {
  Sprite _background;
  List<CanHaveChildMenuItems> _menuItems;
  EventStreamSubscription<MouseEvent> stageClickSubscription;

  bool hasOpenItem = false;

  FileMenu() {
    _background = new Sprite();
    this.addChild(_background);

    _menuItems = List<CanHaveChildMenuItems>();

    _redrawBG();
  }

  void onMenuItemMouseOver(MouseEvent e) {
    if (hasOpenItem == false) {
      return;
    }

    closeOpenItem();

    CanHaveChildMenuItems menuItem = e.currentTarget as CanHaveChildMenuItems;
    menuItem.open();
    hasOpenItem = true;
  }

  void onMenuItemClick(MouseEvent e) {
    CanHaveChildMenuItems menuItem = e.currentTarget as CanHaveChildMenuItems;

    if (menuItem.isOpen) {
      return;
    }

    menuItem.open();
    hasOpenItem = true;
    this.stageClickSubscription = stage.onMouseClick.listen(onStageClick);
    e.stopPropagation();
  }

  FileButton addMenuItem(String text) {
    FileButton menuItem = FileButton(text);
    menuItem.textColor = menuButtonTextColor;
    menuItem._backColor = menuButtonBackColor;
    menuItem._highlightColor = menuButtonHighlightColor;

    menuItem.onMouseClick.listen(onMenuItemClick);
    menuItem.onMouseOver.listen(onMenuItemMouseOver);

    if (_menuItems.length > 0) {
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

  void onStageClick(MouseEvent e) {
    closeOpenItem();
    stageClickSubscription.cancel();
  }

  void closeOpenItem() {
    for (CanHaveChildMenuItems item in _menuItems) {
      if (item.isOpen) {
        item.close();
      }
    }

    hasOpenItem = false;
  }

  get backColor => menuButtonBackColor;

  void _redrawBG() {
    _background.graphics.clear();

    if (_menuItems.length > 0) {
      num height = _menuItems.map((x) => x.height).reduce(max);

      _background.graphics.rect(0, 0, 100, height);
    } else {
      _background.graphics.rect(0, 0, 100, 1);
    }

    _background.graphics.fillColor(menuButtonBackColor);
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
