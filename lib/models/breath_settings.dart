import 'package:hive/hive.dart';

part 'breath_settings.g.dart';

// To regenerate -- flutter packages pub run build_runner build --delete-conflicting-outputs
@HiveType(typeId: 0)
class BreathSettings extends HiveObject {
  BreathSettings(
      {this.length = 22,
      this.ratio = 2,
      this.volume = .5,
      this.deviceID = 0,
      this.noiseEnabled = true});
  @HiveField(0)
  int length;

  @HiveField(1)
  int ratio;

  @HiveField(2)
  double volume;

  @HiveField(3)
  int deviceID;

  @HiveField(4)
  int deviceCount;

  /// Used to disable background noise generation
  @HiveField(5)
  bool noiseEnabled;
}
