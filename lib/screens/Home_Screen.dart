import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Para formatar a data e moeda
import '../models/conta.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Pegando a referência da Box já aberta no main.dart
  final Box<Conta> contasBox = Hive.box<Conta>('contasBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Já Paguei?'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // O ValueListenableBuilder atualiza a tela automaticamente quando a Box muda
      body: ValueListenableBuilder(
        valueListenable: contasBox.listenable(),
        builder: (context, Box<Conta> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text('Nenhuma conta cadastrada. Que alívio! 🎉'),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final conta = box.getAt(index);

              if (conta == null) return const SizedBox.shrink();

              return Dismissible(
                key: Key(conta.key.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // DELETE: Remove a conta do Hive
                  conta.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${conta.titulo} excluída!')),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CheckboxListTile(
                    title: Text(
                      conta.titulo,
                      style: TextStyle(
                        decoration: conta.jaPaguei ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${conta.categoria} • Vence: ${DateFormat('dd/MM/yyyy').format(conta.dataVencimento)}\n'
                          'R\$ ${conta.valor.toStringAsFixed(2)}',
                    ),
                    value: conta.jaPaguei,
                    onChanged: (bool? value) {
                      // UPDATE: Atualiza o status de pagamento no Hive
                      setState(() {
                        conta.jaPaguei = value ?? false;
                        conta.save();
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogNovaConta(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova Conta'),
      ),
    );
  }

  void _mostrarDialogNovaConta(BuildContext context) {
    final tituloController = TextEditingController();
    final valorController = TextEditingController();
    String categoriaSelecionada = 'Moradia';
    DateTime dataSelecionada = DateTime.now();

    final categorias = ['Moradia', 'Alimentação', 'Transporte', 'Educação', 'Lazer', 'Outros'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Adicionar Conta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(labelText: 'Título (Ex: Conta de Luz)'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: valorController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: categoriaSelecionada,
                    items: categorias.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        categoriaSelecionada = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Categoria'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Vencimento: ${DateFormat('dd/MM/yyyy').format(dataSelecionada)}'),
                      TextButton(
                        onPressed: () async {
                          final data = await showDatePicker(
                            context: context,
                            initialDate: dataSelecionada,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (data != null) {
                            setModalState(() {
                              dataSelecionada = data;
                            });
                          }
                        },
                        child: const Text('Alterar Data'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (tituloController.text.isNotEmpty && valorController.text.isNotEmpty) {
                        // CREATE: Instancia e salva a nova conta no Hive
                        final novaConta = Conta(
                          titulo: tituloController.text,
                          valor: double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0,
                          dataVencimento: dataSelecionada,
                          categoria: categoriaSelecionada,
                        );

                        contasBox.add(novaConta);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Salvar Conta'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
