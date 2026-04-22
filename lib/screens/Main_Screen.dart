import 'package:flutter/material.dart';
import '../services/Form_Bills.dart'; // O modal de registo
import 'ManagementBills_Screen.dart';
import 'Home_Dashboard_screen.dart';
import 'ManagementBills_Screen.dart'; // O ecrã da lista agrupada que criámos


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Começamos no índice 0 (Dashboard)
  int _indiceAtual = 0;

  // Lista dos ecrãs que vamos alternar no corpo do Scaffold
  final List<Widget> _ecras = [
    const HomeDashboardScreen(),
    const GerenciarContasScreen(), // Supondo que já criou a base deste ecrã
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O corpo muda consoante o ícone selecionado na barra inferior
      body: _ecras[_indiceAtual],

      // 1. O FAB
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(), // Mantém o formato redondo perfeito
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
        onPressed: () => FormularioConta.mostrarModal(context),
        child: const Icon(Icons.add, size: 32),
      ),

      // 2. A magia do posicionamento: encaixa o FAB ao centro da barra inferior
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 3. A Barra Inferior com o recorte
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Cria o recorte (notch) para o FAB
        notchMargin: 8.0, // A margem de respiro entre o FAB e a barra
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Lado Esquerdo: Dashboard
              _construirItemNavegacao(
                icone: Icons.pie_chart_outline,
                iconeAtivo: Icons.pie_chart,
                texto: 'Resumo',
                indice: 0,
              ),

              // Espaço vazio ao centro para acomodar o FAB
              const SizedBox(width: 48),

              // Lado Direito: Gerir Contas
              _construirItemNavegacao(
                icone: Icons.list_alt_outlined,
                iconeAtivo: Icons.list_alt,
                texto: 'Transações',
                indice: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método auxiliar para criar os botões da barra inferior de forma limpa
  Widget _construirItemNavegacao({
    required IconData icone,
    required IconData iconeAtivo,
    required String texto,
    required int indice,
  }) {
    final isSelecionado = _indiceAtual == indice;
    final cor = isSelecionado ? Theme.of(context).colorScheme.primary : Colors.grey.shade600;

    return InkWell(
      onTap: () => setState(() => _indiceAtual = indice),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelecionado ? iconeAtivo : icone,
              color: cor,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              texto,
              style: TextStyle(
                color: cor,
                fontSize: 12,
                fontWeight: isSelecionado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}