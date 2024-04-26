// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionMessageAdapter extends TypeAdapter<SessionMessage> {
  @override
  final int typeId = 1;

  @override
  SessionMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionMessage(
      id: fields[0] as String,
      cafeId: fields[1] as String,
      senderId: fields[2] as String,
      sentAt: fields[3] as DateTime,
      content: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SessionMessage obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cafeId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.sentAt)
      ..writeByte(4)
      ..write(obj.content);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
