import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

import 'package:stagexl_main_menu/stagexl_main_menu.dart';

MainMenu mainMenu;
Stage stage;

Future<Null> main() async {
  StageOptions options = StageOptions()
    ..backgroundColor = Color.White
    ..renderEngine = RenderEngine.WebGL;

  var canvas = html.querySelector('#stage');
  stage = Stage(canvas, width: 1280, height: 800, options: options);

  var renderLoop = RenderLoop();
  renderLoop.addStage(stage);

  MainMenu mainMenu = MainMenu();
  stage.addChild(mainMenu);

  //add a menu item
  MenuItem file = mainMenu.addMenuItem("File");
  
  file.addMenuItem("New").onMouseClick.listen((Event e) {
    print("New was clicked");
  });

  file.addMenuItem("Open");

  //add a seperator
  file.addSeperator();

  //add sub menu items
  file.addMenuItem("Open Recent")..addMenuItem("File 1")..addMenuItem("File 2");

  //add a checkbox and listen for clicks
  CheckboxMenuItem cb = file.addCheckboxMenuItem("cool", true);
  cb.onIsCheckedChanged.listen((Event e) {
    print(cb.isChecked);
  });

  //add another menu item
  mainMenu.addMenuItem("Edit")..addMenuItem("Cut")..addMenuItem("Copy");

  //set some styles
  mainMenu
    ..fileMenuBackColor = 0xff303030
    ..menuButtonBackColor = 0xff303030
    ..menuButtonHighlightColor = 0xff505050
    ..menuButtonTextColor = 0xffCCCCCC
    ..menuButtonTextSize = 15
    ..menuItemBackColor = 0xff262626
    ..menuItemHighlightColor = 0xff505050
    ..menuItemTextColor = 0xffffffff
    ..menuItemTextSize = 15
    ..seperatorColor = 0xffCCCCCC;

  stage.onResize.listen(onResize);
  onResize(null);
}

void onResize(Event e) {
  mainMenu.x = 0;
  mainMenu.y = 0;
  mainMenu.width = stage.stageWidth;
}
