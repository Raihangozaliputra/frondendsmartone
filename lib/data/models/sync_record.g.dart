// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncRecordAdapter extends TypeAdapter<SyncRecord> {
  @override
  final int typeId = 2;

  @override
  SyncRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncRecord(
      id: fields[0] as String,
      entityType: fields[1] as String,
      entityId: fields[2] as String,
      operation: fields[3] as String,
      data: (fields[4] as Map).cast<String, dynamic>(),
      timestamp: fields[5] as DateTime,
      synced: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SyncRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.entityType)
      ..writeByte(2)
      ..write(obj.entityId)
      ..writeByte(3)
      ..write(obj.operation)
      ..writeByte(4)
      ..write(obj.data)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
