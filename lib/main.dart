import 'dart:async';

import 'package:dart_app_data/dart_app_data.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:prana_hud/models/breath_settings.dart';
import 'package:prana_hud/pages/breath_viz_page.dart';

void main() async {
  var debugPath = AppData.findOrCreate('.prana_hud_debug');
  var releasePath = AppData.findOrCreate('.prana_hud_release');
  Hive.init(
      kReleaseMode ? releasePath.directory.path : debugPath.directory.path);
  Hive.registerAdapter(BreathSettingsAdapter());
  await Hive.openBox('settings');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  double width = 0;
  double height = 0;
  AnimationController _animationController;
  Timer _windowTimer;
  Size _windowSize;
  Size _overlayWindowSize;
  bool lock = true;

  @override
  void initState() {
    _setupWindow();
    _windowTimer = new Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_overlayWindowSize != null && _windowSize != null && !lock) {
        await DesktopWindow.makeOverlay(true);
        if (_windowSize.height != _overlayWindowSize.height) {
          _setupWindow();
        }
      } else if (_overlayWindowSize == null) {
        print("overlay null");
        _setupWindow();
      } else {}
    });
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    super.initState();
  }

  void _setupWindow() async {
    lock = true;
    try {
      var screenSize = await DesktopWindow.getScreenSize();
      _windowSize = await DesktopWindow.getWindowSize();
      _overlayWindowSize = Size(screenSize.width / 7, screenSize.height / 4);
      // center
      // xPos = width/2 - windowSize.width + 130
      double xPos =
          kDebugMode ? screenSize.width - _overlayWindowSize.width : 1;
      double yPos = screenSize.height - _overlayWindowSize.height;
      if (_overlayWindowSize.width > 0 && _overlayWindowSize.height > 0) {
        await DesktopWindow.setMinWindowSize(_overlayWindowSize);
        await DesktopWindow.setWindowSize(_overlayWindowSize);
        await DesktopWindow.setWindowPosition(xPos, yPos);
        await DesktopWindow.makeOverlay(true);
        _windowSize = await DesktopWindow.getWindowSize();
      }
      setState(() {});
      lock = false;
    } catch (e) {
      print("failed to set window");
      lock = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: BreathVizPage());
  }
}
