import 'package:hive/hive.dart';

part 'Conta.g.dart';

@HiveType(typeId: 0)
class Conta extends HiveObject {
  @HiveField(0)
  String titulo;

  @HiveField(1)
  double valor;

  @HiveField(2)
  DateTime dataVencimento;

  @HiveField(3)
  bool jaPaguei;

  @HiveField(4)
  String categoria; // Ex: Moradia, Alimentação, Transporte, Educação

  @HiveField(5)
  String tipo; // Pode ser 'receita' ou 'despesa'

  Conta({
    required this.titulo,
    required this.valor,
    required this.dataVencimento,
    this.jaPaguei = false,
    required this.categoria,
    required this.tipo
  });
}