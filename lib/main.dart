// EconoMY - controle de finanças pessoais
//
// main.dart      - início do app, tema e menu de abas
// models.dart    - classes de dados e funções de formatação
// app_state.dart - dados do app e salvamento
// widgets.dart   - componentes usados em várias telas
// telas.dart     - telas do app

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'telas.dart';
import 'widgets.dart';

const verde = Color(0xFF2E7D32);
const amarelo = Color(0xFFFBC02D);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.carregar();
  runApp(const EconoMyApp());
}

class EconoMyApp extends StatelessWidget {
  const EconoMyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => MaterialApp(
        title: 'EconoMY',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: verde),
        darkTheme: ThemeData(colorSchemeSeed: verde, brightness: Brightness.dark),
        themeMode: app.temaEscuro ? ThemeMode.dark : ThemeMode.light,
        home: const Principal(),
      ),
    );
  }
}

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  int aba = 0;
  final titulos = ['EconoMY', 'Histórico', 'Análise de Gastos', 'Metas e Orçamentos'];

  Widget telaAtual() {
    if (aba == 1) return TelaHistorico();
    if (aba == 2) return TelaAnalise();
    if (aba == 3) return TelaMetas();
    return TelaInicio(verTudo: () => setState(() => aba = 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulos[aba]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => abrir(context, TelaConfiguracoes()),
          ),
        ],
      ),
      body: ListenableBuilder(listenable: app, builder: (context, _) => telaAtual()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: amarelo,
        onPressed: () => abrir(context, TelaCadastro()),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: aba,
        onDestinationSelected: (i) => setState(() => aba = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Histórico'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Análise'),
          NavigationDestination(icon: Icon(Icons.flag), label: 'Metas'),
        ],
      ),
    );
  }
}
