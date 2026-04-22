import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/Conta.dart';

class FormularioConta extends StatefulWidget {
  const FormularioConta({super.key});

  @override
  State<FormularioConta> createState() => _FormularioContaState();

  // Método estático para facilitar a chamada do modal a partir de qualquer ecrã
  static void mostrarModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const FormularioConta(),
    );
  }
}

class _FormularioContaState extends State<FormularioConta> {
  final Box<Conta> contasBox = Hive.box<Conta>('contasBox');

  final tituloController = TextEditingController();
  final valorController = TextEditingController();
  final entradaController = TextEditingController();
  final parcelasController = TextEditingController();

  String tipoSelecionado = 'despesa'; // Por defeito, assumimos que é uma despesa
  bool isParcelado = false;
  DateTime dataSelecionada = DateTime.now();
  String? categoriaSelecionada;

  // Listas dinâmicas de categorias
  final categoriasDespesa = ['Moradia', 'Alimentação', 'Transporte', 'Educação', 'Lazer', 'Outros'];
  final categoriasReceita = ['Salário', 'Freelance', 'Rendimentos', 'Reembolso', 'Outros'];

  @override
  void initState() {
    super.initState();
    categoriaSelecionada = categoriasDespesa.first;
  }

  @override
  void dispose() {
    tituloController.dispose();
    valorController.dispose();
    entradaController.dispose();
    parcelasController.dispose();
    super.dispose();
  }

  void _guardarConta() {
    if (tituloController.text.isEmpty || valorController.text.isEmpty) return;

    double valor = double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0;
    String titulo = tituloController.text;

    if (tipoSelecionado == 'despesa' && isParcelado) {
      double entrada = double.tryParse(entradaController.text.replaceAll(',', '.')) ?? 0.0;
      int qtdParcelas = int.tryParse(parcelasController.text) ?? 1;

      // Regista a Entrada (se existir)
      if (entrada > 0) {
        contasBox.add(Conta(
          titulo: '$titulo (Entrada)',
          valor: entrada,
          dataVencimento: dataSelecionada,
          jaPaguei: true,
          categoria: categoriaSelecionada ?? 'Outros',
          tipo: tipoSelecionado,
        ));
      }

      // Gera as parcelas
      for (int i = 1; i <= qtdParcelas; i++) {
        DateTime dataParcela = DateTime(
          dataSelecionada.year,
          dataSelecionada.month + i,
          dataSelecionada.day,
        );

        contasBox.add(Conta(
          titulo: '$titulo ($i/$qtdParcelas)',
          valor: valor,
          dataVencimento: dataParcela,
          categoria: categoriaSelecionada ?? 'Outros',
          tipo: tipoSelecionado,
        ));
      }
    } else {
      // Guarda como registo único (Receita ou Despesa não parcelada)
      contasBox.add(Conta(
        titulo: titulo,
        valor: valor,
        dataVencimento: dataSelecionada,
        categoria: categoriaSelecionada ?? 'Outros',
        tipo: tipoSelecionado,
      ));
    }

    Navigator.pop(context); // Fecha o modal após guardar
  }

  @override
  Widget build(BuildContext context) {
    // Define qual lista de categorias usar consoante o tipo selecionado
    final categoriasAtuais = tipoSelecionado == 'despesa' ? categoriasDespesa : categoriasReceita;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Novo Registo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Alternador Receita / Despesa
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'receita', label: Text('Receita'), icon: Icon(Icons.arrow_downward, color: Colors.green)),
                ButtonSegment(value: 'despesa', label: Text('Despesa'), icon: Icon(Icons.arrow_upward, color: Colors.red)),
              ],
              selected: {tipoSelecionado},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  tipoSelecionado = newSelection.first;
                  // Atualiza a categoria para a primeira da nova lista correspondente
                  categoriaSelecionada = tipoSelecionado == 'despesa' ? categoriasDespesa.first : categoriasReceita.first;
                  // Se for receita, desativa o parcelamento automaticamente
                  if (tipoSelecionado == 'receita') {
                    isParcelado = false;
                  }
                });
              },
            ),
            const SizedBox(height: 24),

            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: tipoSelecionado == 'despesa' ? 'Título (Ex: Renda)' : 'Título (Ex: Salário)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: valorController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: isParcelado ? 'Valor da Parcela (R\$)' : 'Valor Total (R\$)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: categoriaSelecionada,
              decoration: const InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(),
              ),
              items: categoriasAtuais.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (value) => setState(() => categoriaSelecionada = value),
            ),
            const SizedBox(height: 16),

            // Oculta a área de parcelamento se for "Receita"
            if (tipoSelecionado == 'despesa') ...[
              SwitchListTile(
                title: const Text('É uma despesa parcelada?'),
                contentPadding: EdgeInsets.zero,
                value: isParcelado,
                onChanged: (value) => setState(() => isParcelado = value),
              ),
              if (isParcelado) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: entradaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Entrada (Opcional)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: parcelasController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Nº de Parcelas', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ],

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data:'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(dataSelecionada), style: const TextStyle(fontSize: 16)),
              trailing: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('Alterar'),
                onPressed: () async {
                  final data = await showDatePicker(
                    context: context,
                    initialDate: dataSelecionada,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (data != null) setState(() => dataSelecionada = data);
                },
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: tipoSelecionado == 'despesa' ? Colors.red.shade100 : Colors.green.shade100,
              ),
              onPressed: _guardarConta,
              child: const Text('Guardar Registo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}