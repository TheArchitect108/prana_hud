// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breath_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BreathSettingsAdapter extends TypeAdapter<BreathSettings> {
  @override
  final int typeId = 0;

  @override
  BreathSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreathSettings(
      length: fields[0] as int,
      ratio: fields[1] as int,
      volume: fields[2] as double,
      deviceID: fields[3] as int,
      noiseEnabled: fields[5] as bool,
    )..deviceCount = fields[4] as int;
  }

  @override
  void write(BinaryWriter writer, BreathSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.length)
      ..writeByte(1)
      ..write(obj.ratio)
      ..writeByte(2)
      ..write(obj.volume)
      ..writeByte(3)
      ..write(obj.deviceID)
      ..writeByte(4)
      ..write(obj.deviceCount)
      ..writeByte(5)
      ..write(obj.noiseEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
