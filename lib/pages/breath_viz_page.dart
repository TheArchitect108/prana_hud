import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_audio_desktop/flutter_audio_desktop.dart';
import 'package:hive/hive.dart';

import 'package:prana_hud/models/breath.dart';
import 'package:prana_hud/models/breath_settings.dart';
import 'package:prana_hud/pages/breath_settings_page.dart';
import 'package:prana_hud/widgets/wave_visualizer.dart';

class BreathVizPage extends StatefulWidget {
  BreathVizPage({Key key}) : super(key: key);

  @override
  _BreathVizPageState createState() => _BreathVizPageState();
}

class _BreathVizPageState extends State<BreathVizPage> {
  Timer decay;
  Breath breath;
  BreathSettings _breathSettings;

  int showFor = 0;
  double _prevVolume = 0;

  @override
  void initState() {
    var box = Hive.box('settings');
    if(box.length == 0)
    {
      _breathSettings = new BreathSettings();
      box.add(_breathSettings);
    }else{
      _breathSettings = box.getAt(0);
      if(_breathSettings.noiseEnabled == null)
      {
        _breathSettings.noiseEnabled = true;
        _breathSettings.save();
      }
    }
    breath = new Breath(ratio: _breathSettings.ratio, length: _breathSettings.length);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerHover: (event) async {
          if (decay != null) {
            decay.cancel();
          }
          setState(() {
            showFor = 3;
          });
          decay = Timer.periodic(Duration(seconds: 1), (timer) {
            setState(() {
              showFor--;
            });
            if (showFor == 0) {
              decay.cancel();
            }
          });
        },
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                showFor > 0
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            color: Colors.blue,
                            splashRadius: 1,
                            icon: _breathSettings.volume == 0
                                ? Icon(Icons.volume_mute_sharp)
                                : Icon(Icons.volume_up_sharp),
                            onPressed: () {
                              setState(() {
                                if (_breathSettings.volume != 0) {
                                  _prevVolume = _breathSettings.volume;
                                  _breathSettings.volume = 0.0;
                                } else {
                                  _breathSettings.volume = _prevVolume;
                                }
                              });
                            },
                          ),
                          IconButton(
                            color: Colors.blue,
                            splashRadius: 1,
                            icon: Icon(Icons.settings),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => BreathSettingsPage(
                                      breath: breath,
                                      breathSettings: _breathSettings)));
                            },
                          ),
                        ],
                      )
                    : Container(width: 40, height: 40), // one icon = 40x40
                WaveVisualizer(
                    breath: breath,
                    width: 150,
                    height: 150,
                    color: Colors.blue,
                    breathSettings: _breathSettings,
                    visualizationType: VisualizationType.circle)
              ]),
            ),
          ],
        ));
  }
}
