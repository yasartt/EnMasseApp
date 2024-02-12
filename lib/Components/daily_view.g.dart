// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_view.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyViewAdapter extends TypeAdapter<DailyView> {
  @override
  final int typeId = 0;

  @override
  DailyView read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyView(
      dailyId: fields[0] as int,
      userId: fields[1] as int,
      caption: fields[2] as String?,
      created: fields[3] as DateTime?,
      images: (fields[4] as List?)?.cast<ImageDTO>(),
      userName: fields[5] as String,
      userPhotoId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyView obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.dailyId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.caption)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(4)
      ..write(obj.images)
      ..writeByte(5)
      ..write(obj.userName)
      ..writeByte(6)
      ..write(obj.userPhotoId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyViewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ImageDTOAdapter extends TypeAdapter<ImageDTO> {
  @override
  final int typeId = 1;

  @override
  ImageDTO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageDTO(
      id: fields[0] as String,
      imageName: fields[1] as String,
      dailyId: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ImageDTO obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imageName)
      ..writeByte(2)
      ..write(obj.dailyId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageDTOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
