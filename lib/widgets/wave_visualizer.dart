import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_audio_desktop/flutter_audio_desktop.dart';
import 'package:prana_hud/models/breath_settings.dart';
import '../models/breath.dart';
import 'package:flutter/rendering.dart';
import 'package:dart_numerics/dart_numerics.dart';

enum VisualizationType {
  line,
  circle,
}

class WaveVisualizer extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final Breath breath;
  final VisualizationType visualizationType;
  final BreathSettings breathSettings;
  const WaveVisualizer(
      {Key key,
      @required this.width,
      @required this.height,
      @required this.color,
      @required this.visualizationType,
      @required this.breath,
      @required this.breathSettings})
      : super(key: key);

  @override
  _WaveVisualizerState createState() => _WaveVisualizerState();
}

class _WaveVisualizerState extends State<WaveVisualizer> {
  Uint8List dataArray;
  Timer vizTicker;
  Timer soundTicker;
  int bufferLength = 2048;
  double freqMax = 750;
  math.Random random = new math.Random();
  List<AudioPlayer> breathPlayers = new List<AudioPlayer>();
  AudioPlayer noisePlayer;
  BreathUpdate _breathUpdate;

  int audioTickRate = 100;
  int audioSpeed = 500;
  int vizSpeed = 30;

  double frequency = 0;
  int harmonic = 2;
  double amplitude = 0.1;
  int sampleModifier = 10000;
  int vizTickRate = 30;

  double nthHarmonic(double h, int n) {
    // H1 = 1
    // loop to apply the forumula
    // Hn = H1 + H2 + H3 ... + Hn-1 + Hn-1 + 1/n
    for (int i = 2; i <= n; i++) {
      h += (1 ~/ i);
    }
    return h;
  }

  @override
  void initState() {
    // TODO: implement initState
    widget.breath.startBreath();
    _setupPlayers(10);
    _buildSoundTicker(audioSpeed);
    _buildVizTicker(vizSpeed);
    super.initState();
  }

  // 0 = sine
  // 1 = square
  // 2 = triangle
  // 3 = sawtooth
  AudioPlayer _setupPlayer(int newID) {
    AudioPlayer p = new AudioPlayer(id: newID);
    p.loadWave(0.1, 0, 0);
    try {
      p.setDevice(deviceIndex: widget.breathSettings.deviceID);
    } catch (e) {}
    p.setWaveSampleRate(44800);
    p.setWaveType(2);
    p.play();
    p.setVolume(widget.breathSettings.volume);
    p.setWaveAmplitude(.1);
    return p;
  }

  void _setupPlayers(int count) async {
    for (int x = 0; x < count; x++) {
      breathPlayers.add(_setupPlayer(x));
    }
    noisePlayer = AudioPlayer(id: count);
    noisePlayer.loadNoise(1000, .2, 2);
    noisePlayer.setVolume(0.1);
    noisePlayer.play();
    await breathPlayers.first.getDevices().then((value) {
      setState(() {
        widget.breathSettings.deviceCount = breathPlayers.first.devices.length;
        widget.breathSettings.save();
      });
    });
  }

  void _applySettings() {
    if (widget.breathSettings.deviceCount !=
        breathPlayers.first.devices.length) {
      setState(() {
        widget.breathSettings.deviceCount = breathPlayers.first.devices.length;
      });
    }
    if (breathPlayers.first.volume != widget.breathSettings.volume) {
      breathPlayers.forEach((element) {
        element.setVolume(widget.breathSettings.volume);
      });
    }
    if (breathPlayers.first.deviceIndex != widget.breathSettings.deviceID) {
      breathPlayers.forEach((element) {
        element.setDevice(deviceIndex: widget.breathSettings.deviceID);
        element.setVolume(widget.breathSettings.volume);
      });
    }
    if (widget.breathSettings.noiseEnabled &&
            noisePlayer.volume != widget.breathSettings.volume / 2.5 ||
        noisePlayer.deviceIndex != widget.breathSettings.deviceID) {
      noisePlayer.setDevice(deviceIndex: widget.breathSettings.deviceID);
      noisePlayer.setVolume(widget.breathSettings.volume / 2.5);
    } else if (!widget.breathSettings.noiseEnabled && noisePlayer.volume != 0) {
      noisePlayer.setVolume(0);
    }
  }

  // Follow sound ticket pattern
  void _buildVizTicker(int durationMS) {
    if (vizTicker != null) vizTicker.cancel();
    vizTicker = Timer.periodic(Duration(milliseconds: vizSpeed), (timer) {
      if (vizTickRate != vizSpeed) {
        vizTickRate = vizSpeed;
        _buildVizTicker(vizSpeed);
      }
      dataArray = new Uint8List(bufferLength);
      _breathUpdate = widget.breath.statusUpdate();

      if (_breathUpdate.progress != 0) {
        setState(() {
          if (_breathUpdate.status == BreathStatus.inhaling) {
            dataArray.fillRange(
                0, bufferLength, (_breathUpdate.progress * 100).toInt());
            for (int x = 0; x < dataArray.length; x++) {
              modulate(x, 7, _breathUpdate.progress, true);
              // do stuff to wave here
              // even ripples
              // dataArray[x] = dataArray[x] + random.nextInt(10) < 200
              //     ? dataArray[x] + random.nextInt(10)
              //     : dataArray[x];
            }
          } else if (_breathUpdate.status == BreathStatus.exhaling) {
            dataArray.fillRange(
                0, bufferLength, (_breathUpdate.progress * 100).toInt());
            for (int x = 0; x < dataArray.length; x++) {
              modulate(x, 7, _breathUpdate.progress, false);
              // weird bouncing wave
              //dataArray[x] -= (-3 * sin((4 * dataArray[x]) + 1) * 20).toInt() ;
            }
          }
        });
      }
    });
  }

  void _buildSoundTicker(int durationMS) {
    if (soundTicker != null) soundTicker.cancel();
    soundTicker = Timer.periodic(Duration(milliseconds: audioSpeed), (timer) {
      if (widget.breathSettings.noiseEnabled) {
        noisePlayer.setNoiseAmplitude(_breathUpdate.progress + .4);
        noisePlayer.setNoiseSeed((_breathUpdate.progress * 1000).toInt());
      }
      _applySettings();
      if (audioTickRate != audioSpeed) {
        _buildSoundTicker(audioSpeed);
        audioTickRate = audioSpeed;
      }
      breathPlayers.forEach((element) async {
        if (element.id.isEven) {
          element.setWaveFrequency(frequency + 60);
        } else {
          element.setWaveFrequency(frequency + 30);
        }
      });
    });
  }

  int group = 1;
  double mult = 1;
  double modifier;
  void modulate(int x, int groups, double progress, bool pos) {
    audioSpeed = 500;
    vizSpeed = 50;
    harmonic = 2;
    // wheel = 77
    // stargate = 18
    // hb 5
    groups = 4;
    //harmonic = (progress*200).toInt();
    for (int y = 1; y < groups; y++) {
      // wheel = .0001
      // leaf, stargate .00111
      // heartbeat 0.0009109
      //harmonic = group;
      mult = .0022;
      mult = pos ? mult : mult * -1;
      modifier = sin(mult * group) * progress;
      pos
          ? dataArray[x] = (dataArray[x] + modifier).truncate()
          : dataArray[x] = (dataArray[x] - modifier).truncate();
      //dataArray[x] = ((progress * 100 * sin(group * mult) + modifier).toInt()).toInt();
      //frequency = (dataArray[x] + (modifier)) * base;
      frequency = (progress * 220);
      //frequency = modifier * 220;
      freqMax = 9000;
      if (frequency > freqMax) {
        frequency = freqMax.toDouble() * progress;
      }
      if (frequency < -freqMax) {
        frequency = freqMax;
      }
      // dataArray[x] = (frequency ~/ base).toInt();
      if (y == groups + 5) {
        group = 5;
      } else {
        group++;
      }
    }
  }

  void dispose() {
    breathPlayers.forEach((element) {
      element.stop();
    });
    vizTicker.cancel();
    soundTicker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: WavePainter(
          drawList: dataArray,
          width: widget.width,
          height: widget.height,
          bufferSize: bufferLength,
          color: widget.color != null ? widget.color : Colors.blue,
          visualizationType: widget.visualizationType),
    );
  }
}

class WavePainter extends CustomPainter {
  final Uint8List drawList;
  final double width;
  final double height;
  final int bufferSize;
  final VisualizationType visualizationType;
  Color color;

  WavePainter(
      {Key key,
      @required this.drawList,
      @required this.width,
      @required this.height,
      @required this.bufferSize,
      @required this.color,
      @required this.visualizationType});
  @override
  void paint(Canvas canvas, Size size) {
    switch (visualizationType) {
      case VisualizationType.circle:
        circleVisualizer(canvas);
        break;
      case VisualizationType.line:
        lineVisualizer(canvas);
        break;
    }
  }

  Float32List points;

  double mapOneRangeToAnother(double sourceNumber, double fromA, double fromB,
      double toA, double toB, int decimalPrecision) {
    double deltaA = fromB - fromA;
    double deltaB = toB - toA;
    double scale = deltaB / deltaA;
    double negA = -1 * fromA;
    double offset = (negA * scale) + toA;
    double finalNumber = (sourceNumber * scale) + offset;
    int calcScale = math.pow(10, decimalPrecision);
    return (finalNumber * calcScale).round() / calcScale;
  }

  void circleVisualizer(Canvas canvas) {
    if (drawList != null) {
      //make waveform usable
      double resolution = drawList.length.toDouble();
      var waveform = drawList;
      var waveInter = (waveform.length / drawList.length).floor();
      var reducedWave = new List<double>();
      var r = height * 0.005;
      var path = new Path();

      for (var i = 0; i < resolution; i++) {
        reducedWave.add(waveform[i * waveInter].toDouble());
      }

      //draw waveform
      for (var i = 0; i < resolution; i++) {
        var off = mapOneRangeToAnother(reducedWave[i], -1, 1, -r / 2, r / 2, 1);
        var angle =
            mapOneRangeToAnother(i.toDouble(), 0, resolution, 0, pi * 2, 1);
        var y = ((r - r * 0.1) + off) * sin(angle);
        var x = ((r - r * 0.1) + off) * cos(angle);
        if (i == 0) {
          path.moveTo(x + 50, y + 50);
        } else {
          path.lineTo(x + 50, y + 50);
        }
      }
      if (!path.getBounds().isEmpty)
        canvas.drawPath(
            path,
            new Paint()
              ..color = color.withOpacity(1)
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke);
    }
  }

  void lineVisualizer(Canvas canvas) {
    if (drawList != null) {
      var paint = new Paint();
      paint.color = Colors.white;
      var path = new Path();
      double x = 0;
      var sliceWidth = width * 1.0 / bufferSize;
      canvas.drawPath(path, paint);
      for (var i = 0; i < bufferSize; i++) {
        var v = drawList[i] / 128.0;
        var y = v * height / 2;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        x += sliceWidth;
      }
      //path = Path();

      canvas.drawPath(
          path,
          new Paint()
            ..color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                .withOpacity(1.0)
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return true;
  }
}
