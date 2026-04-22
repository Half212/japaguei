import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:japaguei/screens/Home_Screen.dart';
import 'package:japaguei/screens/Main_Screen.dart';
import 'models/Conta.dart';
import 'models/Financiamento.dart';


void main() async {
  // Garante que os bindings do Flutter estão inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Hive
  await Hive.initFlutter();

  // Registra os Adapters
  Hive.registerAdapter(ContaAdapter());
  Hive.registerAdapter(FinanciamentoAdapter());

  // Abre as Boxes (tabelas)
  await Hive.openBox<Conta>('contasBox');
  await Hive.openBox<Financiamento>('financiamentosBox');

  runApp(const JaPagueiApp());
}

class JaPagueiApp extends StatelessWidget {
  const JaPagueiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Já Paguei?',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(), // Tela principal que criaremos a seguir
    );
  }
}