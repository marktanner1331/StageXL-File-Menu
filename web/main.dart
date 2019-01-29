import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'dart:math';
import './FileMenu.dart';

FileMenu fileMenu;
Stage stage;

Future<Null> main() async {
  StageOptions options = StageOptions()
    ..backgroundColor = Color.White
    ..renderEngine = RenderEngine.WebGL;

  var canvas = html.querySelector('#stage');
  stage = Stage(canvas, width: 1280, height: 800, options: options);

  var renderLoop = RenderLoop();
  renderLoop.addStage(stage);

  fileMenu = FileMenu();
  FileButton file = fileMenu.addMenuItem("File");
  file.addMenuItem("New");
  file.addMenuItem("Open");
  file.addSeperator();

  file.addMenuItem("Open Recent")
  ..addMenuItem("File 1")
  ..addMenuItem("File 2");

  file.addCheckboxMenuItem("cool", true);

  fileMenu.addMenuItem("Edit")
  ..addMenuItem("Cut")
  ..addMenuItem("Copy");
  stage.addChild(fileMenu);

  stage.onResize.listen(onResize);
  onResize(null);
}

void onResize(Event e) {
  fileMenu.x = 0;
  fileMenu.y = 0;
  fileMenu.width = stage.stageWidth;
}
