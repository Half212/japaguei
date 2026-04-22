import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/Conta.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Já Paguei?'),
        centerTitle: true,
      ),
      // O ValueListenableBuilder mantém os gráficos atualizados em tempo real
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Conta>('contasBox').listenable(),
        builder: (context, Box<Conta> box, _) {
          final now = DateTime.now();

          // 1. Filtrando apenas as transações do mês e ano atuais
          final contasMesAtual = box.values.where((c) =>
          c.dataVencimento.month == now.month &&
              c.dataVencimento.year == now.year
          ).toList();

          double receitas = 0;
          double despesas = 0;
          Map<String, double> despesasPorCategoria = {};

          // 2. Calculando os totais
          for (var conta in contasMesAtual) {
            // Assumindo que você adicionou o campo "tipo" (receita/despesa) no modelo
            if (conta.tipo == 'receita') {
              receitas += conta.valor;
            } else {
              despesas += conta.valor;

              // 3. Agrupando valores para o gráfico de pizza
              despesasPorCategoria.update(
                  conta.categoria,
                      (valorExistente) => valorExistente + conta.valor,
                  ifAbsent: () => conta.valor
              );
            }
          }

          double saldo = receitas - despesas;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cards de Resumo Financeiro
                _buildResumoCards(receitas, despesas, saldo),

                const SizedBox(height: 40),

                // Gráfico de Pizza (Despesas por Categoria)
                if (despesas > 0) ...[
                  const Text(
                    'Para onde está indo o dinheiro?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: _buildGraficoPizza(despesasPorCategoria),
                  ),
                ] else ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Nenhuma despesa registrada neste mês. 🎉',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget extraído para montar os cards superiores
  Widget _buildResumoCards(double receitas, double despesas, double saldo) {
    return Column(
      children: [
        Card(
          elevation: 4,
          color: saldo >= 0 ? Colors.green.shade100 : Colors.red.shade100,
          child: ListTile(
            title: const Text('Saldo do Mês', style: TextStyle(fontSize: 16)),
            trailing: Text(
              'R\$ ${saldo.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: saldo >= 0 ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Card(
                child: ListTile(
                  title: const Text('Receitas', style: TextStyle(fontSize: 14)),
                  subtitle: Text('R\$ ${receitas.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: ListTile(
                  title: const Text('Despesas', style: TextStyle(fontSize: 14)),
                  subtitle: Text('R\$ ${despesas.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget extraído para montar o gráfico
  Widget _buildGraficoPizza(Map<String, double> categorias) {
    // Paleta de cores para as fatias do gráfico
    final cores = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.pink, Colors.brown
    ];

    int colorIndex = 0;
    List<PieChartSectionData> sections = [];

    categorias.forEach((nomeDaCategoria, valorGasto) {
      sections.add(
          PieChartSectionData(
            color: cores[colorIndex % cores.length],
            value: valorGasto,
            title: nomeDaCategoria,
            radius: 60,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          )
      );
      colorIndex++;
    });

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: sections,
      ),
    );
  }
}