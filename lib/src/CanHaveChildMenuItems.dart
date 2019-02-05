import './HasMainMenuStyle.dart';
import './MenuItemGroup.dart';
import './MenuItem.dart';
import './SimpleMenuItem.dart';
import './Seperator.dart';
import './CheckboxMenuItem.dart';
import './CheckboxMenuItemInner.dart';

mixin CanHaveChildMenuItems on HasMainMenuStyle {
  MenuItemGroup menuItems = MenuItemGroup();

  ///adds a menu item that can have child menu items
  MenuItem addMenuItem(String text) {
    SimpleMenuItem menuItem = SimpleMenuItem(style, menuItems, text);
  
    menuItems.addMenuItem(menuItem);
    return menuItem;
  }

  ///adds a seperator, a horizontal bar that seperates menu items
  void addSeperator() {
    Seperator menuItem = new Seperator(style, menuItems);

    menuItems.addMenuItem(menuItem);
  }

  ///adds a checkbox menu item, which can be checked or unchecked
  CheckboxMenuItem addCheckboxMenuItem(String text, bool isChecked) {
    CheckboxMenuItemInner menuItem =
        CheckboxMenuItemInner(style, menuItems, text, isChecked);

    menuItems.addMenuItem(menuItem);
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