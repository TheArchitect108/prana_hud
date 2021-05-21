import 'package:flutter/material.dart';
import 'package:prana_hud/models/breath.dart';
import 'package:prana_hud/models/breath_settings.dart';
import 'package:prana_hud/widgets/number_setter.dart';

class BreathSettingsPage extends StatefulWidget {
  Breath breath;
  BreathSettings breathSettings;
  BreathSettingsPage(
      {Key key, @required this.breath, @required this.breathSettings})
      : super(key: key);

  @override
  _BreathSettingsPageState createState() => _BreathSettingsPageState();
}

class _BreathSettingsPageState extends State<BreathSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: Column(children: [
        Container(
            height: 40,
            padding: EdgeInsets.only(top: 10, left: 10),
            child: Row(
              children: [
                GestureDetector(
                  child: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).accentColor,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                Spacer(
                  flex: 1,
                ),
                Text(
                  "Breath Settings",
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    decoration: TextDecoration.none,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Spacer(flex: 2)
              ],
            )),
        Divider(),
        Container(
            height: 210,
            child: ListView(
              children: [
                _buildLengthSetting(),
                _buildRatioSetting(),
                _buildVolumeSetting(),
                _buildDevicesSetting(),
                _buildNoiseEnabledSetting()
              ],
            ))
      ]),
    );
  }

  /// Allows user to set the total length of breath -- default 30
  Widget _buildLengthSetting() => Card(
          child: ListTile(
        leading: Icon(
          Icons.timelapse,
          color: Theme.of(context).accentColor,
          size: 20,
        ),
        title: Text(
          "Length",
          style: TextStyle(
            color: Theme.of(context).accentColor,
          ),
        ),
        trailing: NumberSetter(
          showDecrement: widget.breath.length > 4,
          showIncrement: widget.breath.length < 98,
          value: widget.breath.length,
          onDecrement: () {
            if (widget.breath.length > 4) {
              setState(() {
                widget.breath.length -= 2;
                widget.breath.setBreath(newLength: widget.breath.length);
                widget.breathSettings.length = widget.breath.length;
                widget.breathSettings.save();
              });
            }
          },
          onIncrement: () {
            if (widget.breath.length < 100) {
              setState(() {
                widget.breath.length += 2;
                widget.breath.setBreath(newLength: widget.breath.length);
                widget.breathSettings.length = widget.breath.length;
                widget.breathSettings.save();
              });
            }
          },
        ),
      ));

  /// Allow user to control how the breath is split -- default 2
  Widget _buildRatioSetting() => Card(
          child: ListTile(
        leading: Icon(
          Icons.pie_chart,
          color: Theme.of(context).accentColor,
          size: 20,
        ),
        title: Text(
          "Split",
          style: TextStyle(
            color: Theme.of(context).accentColor,
          ),
        ),
        trailing: NumberSetter(
          showDecrement: widget.breath.ratio > 1,
          showIncrement: widget.breath.ratio < 4,
          value: widget.breath.ratio,
          onDecrement: () {
            if (widget.breath.ratio > 1) {
              setState(() {
                widget.breath.ratio -= 1;
                widget.breath.setBreath(newRatio: widget.breath.ratio);
                widget.breathSettings.ratio = widget.breath.ratio;
                widget.breathSettings.save();
              });
            }
          },
          onIncrement: () {
            if (widget.breath.ratio < 5) {
              setState(() {
                widget.breath.ratio += 1;
                widget.breath.setBreath(newRatio: widget.breath.ratio);
                widget.breathSettings.ratio = widget.breath.ratio;
                widget.breathSettings.save();
              });
            }
          },
        ),
      ));

  /// Allows user to control volume of all audio
  Widget _buildVolumeSetting() => Card(
      child: ListTile(
          leading: Icon(
            Icons.volume_down,
            color: Theme.of(context).accentColor,
            size: 20,
          ),
          title: Text(
            "Volume",
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
          trailing: Container(
              width: 100,
              child: Slider(
                value: widget.breathSettings.volume,
                min: 0,
                max: 1,
                divisions: 100,
                onChanged: (value) {
                  setState(() {
                    widget.breathSettings.volume = value;
                    widget.breathSettings.save();
                  });
                },
              ))));

  /// Allows user to rotate through available sound devices
  Widget _buildDevicesSetting() => Card(
      child: ListTile(
          leading: Icon(
            Icons.surround_sound,
            color: Theme.of(context).accentColor,
            size: 20,
          ),
          title: Text(
            "Device",
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
          trailing: NumberSetter(
            value: widget.breathSettings.deviceID,
            showDecrement: widget.breathSettings.deviceID > 0,
            showIncrement: widget.breathSettings.deviceID <
                widget.breathSettings.deviceCount - 2,
            onDecrement: () {
              setState(() {
                widget.breathSettings.deviceID--;
                widget.breathSettings.save();
              });
            },
            onIncrement: () {
              setState(() {
                widget.breathSettings.deviceID++;
                widget.breathSettings.save();
              });
            },
          )));

  /// Allows user to enable or disable white noise
  Widget _buildNoiseEnabledSetting() => Card(
      child: ListTile(
          leading: Icon(
            Icons.radio,
            color: Theme.of(context).accentColor,
            size: 20,
          ),
          title: Text(
            "Back Noise",
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
          trailing: Switch(
              value: widget.breathSettings.noiseEnabled,
              onChanged: (value) {
                setState(() {
                  widget.breathSettings.noiseEnabled = value;
                  widget.breathSettings.save();
                });
              })));
}
