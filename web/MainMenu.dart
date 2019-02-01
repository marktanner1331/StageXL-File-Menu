import 'dart:async';

import 'package:stagexl/stagexl.dart';
import 'dart:math';

mixin _MainMenuStyle {
  int fileMenuBackColor = 0xff303030;

  int menuButtonBackColor = 0xff303030;
  int menuButtonHighlightColor = 0xff505050;
  int menuButtonTextColor = 0xffCCCCCC;
  int menuButtonTextSize = 15;

  int menuItemBackColor = 0xff262626;
  int menuItemHighlightColor = 0xff505050;
  int menuItemTextColor = 0xffffffff;
  int menuItemTextSize = 15;

  int seperatorColor = 0xffCCCCCC;
}

mixin _HasMainMenuStyle {
  _MainMenuStyle style;
}

mixin _FullWidthMenuItem on DisplayObject {
  num preferredWidth = 1;
  num get minWidth;
  void relayout();
}

abstract class MenuItem with _HasMainMenuStyle, CanHaveChildMenuItems {
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

mixin CanHaveChildMenuItems on _HasMainMenuStyle {
  _MenuItemGroup _menuItems = _MenuItemGroup();

  MenuItem addMenuItem(String text) {
    _SimpleMenuItem menuItem = _SimpleMenuItem(style, _menuItems, text);

    _menuItems.addMenuItem(menuItem);
    return menuItem;
  }

  void addSeperator() {
    _Seperator menuItem = new _Seperator(style, _menuItems);

    _menuItems.addMenuItem(menuItem);
  }

  CheckboxMenuItem addCheckboxMenuItem(String text, bool isChecked) {
    _CheckboxMenuItem menuItem =
        _CheckboxMenuItem(style, _menuItems, text, isChecked);

    _menuItems.addMenuItem(menuItem);
    return menuItem;
  }

  bool _isOpen = false;
  void _open() {
    _isOpen = true;
  }

  void _close() {
    _isOpen = false;
  }
}

class MenuButton extends Sprite
    with _HasMainMenuStyle, CanHaveChildMenuItems
    implements MenuItem {
  TextField _label;

  MenuButton(_MainMenuStyle style, String text) {
    this.style = style;
    _menuItems.style = style;

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

    _menuItems.relayout();
  }

  void redrawBG(int color) {
    graphics.clear();
    graphics.rect(0, 0, _label.textWidth + 16, _label.textHeight + 10);
    graphics.fillColor(color);
  }

  @override
  void _close() {
    super._close();
    _menuItems.closeOpenMenuItems();
    stage.removeChild(_menuItems);
  }

  @override
  void _open() {
    super._open();
    _menuItems
      ..x = x
      ..y = height;
    stage.addChild(_menuItems);
  }
}

class _MenuItemGroup extends Sprite with _HasMainMenuStyle {
  List<_FullWidthMenuItem> _menuItems;

  _MenuItemGroup() {
    _menuItems = List<_FullWidthMenuItem>();
  }

  void relayout() {
    num deltaY = 7;

    if (_menuItems.length > 0) {
      for (_FullWidthMenuItem menuItem in _menuItems) {
        menuItem.relayout();
        menuItem.y = deltaY;
        deltaY += menuItem.height;
      }

      num tempWidth = this.minWidth;
      for (_FullWidthMenuItem menuItem in _menuItems) {
        menuItem.preferredWidth = tempWidth;
      }

      _redrawBG(tempWidth, deltaY + 7);
    }
  }

  void addMenuItem(_FullWidthMenuItem menuItem) {
    graphics.clear();

    menuItem.y = max(this.height, 7);

    _menuItems.add(menuItem);
    addChild(menuItem);

    num tempWidth = this.minWidth;
    for (_FullWidthMenuItem menuItem in _menuItems) {
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
    for (_FullWidthMenuItem menuItem in _menuItems) {
      if (menuItem is CanHaveChildMenuItems) {
        CanHaveChildMenuItems canHaveChildMenuItems =
            (menuItem as CanHaveChildMenuItems);
        if (canHaveChildMenuItems._isOpen) {
          canHaveChildMenuItems._close();
        }
      }
    }
  }
}

class _SimpleMenuItem extends Sprite
    with _HasMainMenuStyle, CanHaveChildMenuItems, _FullWidthMenuItem
    implements MenuItem {
  TextField _label;
  _MenuItemGroup _parentGroup;

  _SimpleMenuItem(
      _MainMenuStyle style, _MenuItemGroup parentGroup, String text) {
    this.style = style;
    this._menuItems.style = style;
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

    _menuItems.relayout();
  }

  void onHadMouseOver(MouseEvent e) {
    redrawBG(style.menuItemHighlightColor);
    _parentGroup.closeOpenMenuItems();
    _open();
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
  void _close() {
    super._close();
    _menuItems.closeOpenMenuItems();
    stage.removeChild(_menuItems);
  }

  @override
  void _open() {
    super._open();
    Point p = Point(preferredWidth, 0);
    p = localToGlobal(p);

    _menuItems
      ..x = p.x
      ..y = p.y;
    stage.addChild(_menuItems);
  }
}

abstract class CheckboxMenuItem {
  static const String IS_CHECKED_CHANGED = "IS_CHECKED_CHANGED";

  bool isChecked;
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

class _CheckboxMenuItem extends Sprite
    with _FullWidthMenuItem, _HasMainMenuStyle
    implements CheckboxMenuItem {
  static const EventStreamProvider<Event> _onIsCheckedChangedEvent =
      const EventStreamProvider<Event>(CheckboxMenuItem.IS_CHECKED_CHANGED);

  TextField _label;

  bool _isChecked;
  _MenuItemGroup _parentGroup;

  _CheckboxMenuItem(_MainMenuStyle style, _MenuItemGroup parentGroup,
      String text, bool isChecked) {
    this.style = style;
    this._parentGroup = parentGroup;
    this._isChecked = isChecked;

    _label = TextField()
      ..text = text
      ..x = 8
      ..y = 5
      ..autoSize = TextFieldAutoSize.LEFT
      ..mouseEnabled = false;
    ;

    this.addChild(_label);

    this.mouseCursor = MouseCursor.POINTER;

    this.onMouseOver.listen(didMouseOver);
    this.onMouseOut.listen((MouseEvent e) => redrawBG(style.menuItemBackColor));
    this.onMouseClick.listen(didMouseClick);
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
    _label.text = _label.text;

    _label.x = _label.textHeight + 15;
    _label.width = _label.textWidth;
    _label.height = _label.textHeight;

    redrawBG(style.menuItemBackColor);
  }

  void didMouseOver(MouseEvent e) {
    redrawBG(style.menuItemHighlightColor);
    _parentGroup.closeOpenMenuItems();
  }

  void didMouseClick(MouseEvent e) {
    isChecked = !isChecked;
  }

  void redrawBG(int color) {
    graphics.clear();

    num tempHeight = _label.textHeight + 12;

    graphics.beginPath();
    graphics.rect(0, 0, preferredWidth, tempHeight);
    graphics.fillColor(color);
    graphics.closePath();

    graphics.beginPath();
    graphics.rect(7, 7, tempHeight - 14, tempHeight - 14);

    if (isChecked) {
      graphics.moveTo(9, tempHeight / 2);
      graphics.lineTo(7 + (tempHeight - 14) / 3, tempHeight - 9);
      graphics.lineTo(tempHeight - 9, 9);
    }

    graphics.strokeColor(style?.menuItemTextColor ?? 0xff000000);
    graphics.closePath();
  }

  @override
  bool get isChecked => _isChecked;

  @override
  set isChecked(bool value) {
    _isChecked = value;
    dispatchEvent(new Event(CheckboxMenuItem.IS_CHECKED_CHANGED));
  }

  @override
  num get minWidth => _label.x + _label.textWidth + 16;

  @override
  EventStream<Event> get onIsCheckedChanged {
    return _onIsCheckedChangedEvent.forTarget(this);
  }
}

class _Seperator extends Sprite with _FullWidthMenuItem, _HasMainMenuStyle {
  _MenuItemGroup _parentGroup;

  _Seperator(_MainMenuStyle style, _MenuItemGroup parentGroup) {
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

class MainMenu extends DisplayObjectContainer with _MainMenuStyle {
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
    menuItem._open();
    _hasOpenItem = true;
  }

  void _onMenuItemClick(MouseEvent e) {
    CanHaveChildMenuItems menuItem = e.currentTarget as CanHaveChildMenuItems;

    if (menuItem._isOpen) {
      return;
    }

    menuItem._open();
    _hasOpenItem = true;
    this._stageClickSubscription = stage.onMouseClick.listen(_onStageClick);
    e.stopPropagation();
  }

  MenuItem addMenuItem(String text) {
    MenuButton menuItem = MenuButton(this, text);

    menuItem.onMouseClick.listen(_onMenuItemClick);
    menuItem.onMouseOver.listen(_onMenuItemMouseOver);

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

  void _onStageClick(MouseEvent e) {
    _closeOpenItem();
    _stageClickSubscription.cancel();
  }

  void _closeOpenItem() {
    for (CanHaveChildMenuItems item in _menuItems) {
      if (item._isOpen) {
        item._close();
      }
    }

    _hasOpenItem = false;
  }

  void _redrawBG() {
    _background.graphics.clear();

    if (_menuItems.length > 0) {
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
