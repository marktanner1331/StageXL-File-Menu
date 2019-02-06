import 'package:stagexl/stagexl.dart';
import './FullWidthMenuItem.dart';
import './HasMainMenuStyle.dart';
import './CheckboxMenuItem.dart';
import './MenuItemGroup.dart';
import './MainMenuStyle.dart';

class CheckboxMenuItemInner extends Sprite
    with FullWidthMenuItem, HasMainMenuStyle
    implements CheckboxMenuItem {
  static const EventStreamProvider<Event> _onIsCheckedChangedEvent =
      const EventStreamProvider<Event>(CheckboxMenuItem.IS_CHECKED_CHANGED);

  TextField _label;

  bool _isChecked;
  MenuItemGroup _parentGroup;

  CheckboxMenuItemInner(MainMenuStyle style, MenuItemGroup parentGroup,
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
