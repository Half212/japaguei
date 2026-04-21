// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Financiamento.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinanciamentoAdapter extends TypeAdapter<Financiamento> {
  @override
  final int typeId = 1;

  @override
  Financiamento read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Financiamento(
      titulo: fields[0] as String,
      valorParcela: fields[1] as double,
      totalParcelas: fields[2] as int,
      parcelasPagas: fields[3] as int,
      diaVencimento: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Financiamento obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.titulo)
      ..writeByte(1)
      ..write(obj.valorParcela)
      ..writeByte(2)
      ..write(obj.totalParcelas)
      ..writeByte(3)
      ..write(obj.parcelasPagas)
      ..writeByte(4)
      ..write(obj.diaVencimento);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanciamentoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
