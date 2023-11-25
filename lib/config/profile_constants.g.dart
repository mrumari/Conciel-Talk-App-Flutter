// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_constants.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveFileAdapter extends TypeAdapter<HiveFile> {
  @override
  final int typeId = 0;

  @override
  HiveFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveFile(
      location: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveFile obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.location)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MandatoryAdapter extends TypeAdapter<Mandatory> {
  @override
  final int typeId = 1;

  @override
  Mandatory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Mandatory(
      nickname: fields[0] as String,
      phoneNumber: fields[1] as String,
      email: fields[2] as String,
      residentialAddress: fields[3] as Address?,
    );
  }

  @override
  void write(BinaryWriter writer, Mandatory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.nickname)
      ..writeByte(1)
      ..write(obj.phoneNumber)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.residentialAddress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MandatoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AddressAdapter extends TypeAdapter<Address> {
  @override
  final int typeId = 2;

  @override
  Address read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Address(
      street: fields[0] as String,
      streetNumber: fields[1] as String,
      city: fields[2] as String,
      region: fields[3] as String,
      postcode: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Address obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.street)
      ..writeByte(1)
      ..write(obj.streetNumber)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.region)
      ..writeByte(4)
      ..write(obj.postcode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
