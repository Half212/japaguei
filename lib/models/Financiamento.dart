import 'package:hive/hive.dart';

part 'Financiamento.g.dart';

@HiveType(typeId: 1)
class Financiamento extends HiveObject {
  @HiveField(0)
  String titulo; // Ex: Carro, Apartamento

  @HiveField(1)
  double valorParcela;

  @HiveField(2)
  int totalParcelas;

  @HiveField(3)
  int parcelasPagas;

  @HiveField(4)
  int diaVencimento; // O dia do mês em que a parcela vence

  Financiamento({
    required this.titulo,
    required this.valorParcela,
    required this.totalParcelas,
    this.parcelasPagas = 0,
    required this.diaVencimento,
  });

  // Um getter útil para saber quantas faltam
  int get parcelasRestantes => totalParcelas - parcelasPagas;
}