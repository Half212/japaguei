import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/Conta.dart';

class GerenciarContasScreen extends StatelessWidget {
  const GerenciarContasScreen({super.key});

  // Função para agrupar os dados
  Map<String, Map<String, List<Conta>>> _agruparContas(Iterable<Conta> contas) {
    final Map<String, Map<String, List<Conta>>> agrupado = {};

    for (var conta in contas) {
      // Cria a chave do Mês/Ano (Ex: "03/2026")
      String mesAno = DateFormat('MM/yyyy').format(conta.dataVencimento);
      String categoria = conta.categoria;

      agrupado.putIfAbsent(mesAno, () => {});
      agrupado[mesAno]!.putIfAbsent(categoria, () => []);
      agrupado[mesAno]![categoria]!.add(conta);
    }

    return agrupado;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Lançamentos')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Conta>('contasBox').listenable(),
        builder: (context, Box<Conta> box, _) {
          if (box.isEmpty) return const Center(child: Text('Nenhum lançamento.'));

          // Ordena as contas por data antes de agrupar
          final contasList = box.values.toList()
            ..sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));

          final contasAgrupadas = _agruparContas(contasList);

          return ListView.builder(
            itemCount: contasAgrupadas.keys.length,
            itemBuilder: (context, indexMes) {
              String mesAno = contasAgrupadas.keys.elementAt(indexMes);
              var categoriasDoMes = contasAgrupadas[mesAno]!;

              return ExpansionTile(
                title: Text('Mês: $mesAno', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                initiallyExpanded: true,
                children: categoriasDoMes.keys.map((categoria) {
                  var contasDaCategoria = categoriasDoMes[categoria]!;

                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(categoria, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                        ...contasDaCategoria.map((conta) => ListTile(
                          title: Text(conta.titulo),
                          subtitle: Text('R\$ ${conta.valor.toStringAsFixed(2)} - ${conta.tipo}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // Chamar modal de edição aqui
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => conta.delete(),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para a tela/modal de cadastro (o que fizemos no passo anterior)
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}