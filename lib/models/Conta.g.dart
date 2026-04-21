// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Conta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContaAdapter extends TypeAdapter<Conta> {
  @override
  final int typeId = 0;

  @override
  Conta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conta(
      titulo: fields[0] as String,
      valor: fields[1] as double,
      dataVencimento: fields[2] as DateTime,
      jaPaguei: fields[3] as bool,
      categoria: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Conta obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.titulo)
      ..writeByte(1)
      ..write(obj.valor)
      ..writeByte(2)
      ..write(obj.dataVencimento)
      ..writeByte(3)
      ..write(obj.jaPaguei)
      ..writeByte(4)
      ..write(obj.categoria);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
