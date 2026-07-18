// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileEntityAdapter extends TypeAdapter<FileEntity> {
  @override
  final int typeId = 0;

  @override
  FileEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileEntity(
      id: fields[0] as int,
      tempName: fields[1] as String?,
      path: fields[2] as String?,
      code: fields[3] as String,
      saved: fields[4] as bool,
      cursor: (fields[5] as List).cast<int>(),
      readOnly: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FileEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tempName)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.code)
      ..writeByte(4)
      ..write(obj.saved)
      ..writeByte(5)
      ..write(obj.cursor)
      ..writeByte(6)
      ..write(obj.readOnly);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
