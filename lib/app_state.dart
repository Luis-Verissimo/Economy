import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AppState extends ChangeNotifier {
  SharedPreferences? prefs;

  List<Movimentacao> movimentacoes = [];
  String nome = 'Usuário';
  String moeda = 'R\$';
  bool temaEscuro = false;
  double meta = 0;
  Map<String, double> limites = {};
  DateTime mes = DateTime(DateTime.now().year, DateTime.now().month);

  Future<void> carregar() async {
    prefs = await SharedPreferences.getInstance();
    final p = prefs!;

    final lista = p.getString('movs');
    if (lista != null) {
      movimentacoes = (jsonDecode(lista) as List)
          .map((e) => Movimentacao.fromJson(e))
          .toList();
    }
    final lim = p.getString('limites');
    if (lim != null) {
      (jsonDecode(lim) as Map).forEach((k, v) => limites[k] = (v as num).toDouble());
    }
    nome = p.getString('nome') ?? nome;
    moeda = p.getString('moeda') ?? moeda;
    temaEscuro = p.getBool('escuro') ?? false;
    meta = p.getDouble('meta') ?? 0;
  }

  // atualiza as telas e grava tudo no aparelho
  void salvar() {
    notifyListeners();
    final p = prefs;
    if (p == null) return;
    p.setString('movs', jsonEncode(movimentacoes.map((m) => m.toJson()).toList()));
    p.setString('limites', jsonEncode(limites));
    p.setString('nome', nome);
    p.setString('moeda', moeda);
    p.setBool('escuro', temaEscuro);
    p.setDouble('meta', meta);
  }

  void salvarMovimentacao(Movimentacao m) {
    movimentacoes.removeWhere((e) => e.id == m.id);
    movimentacoes.add(m);
    movimentacoes.sort((a, b) => b.data.compareTo(a.data));
    salvar();
  }

  void excluirMovimentacao(String id) {
    movimentacoes.removeWhere((m) => m.id == id);
    salvar();
  }

  void limparTudo() {
    movimentacoes.clear();
    limites.clear();
    meta = 0;
    salvar();
  }

  void mudarMes(int quantidade) {
    mes = DateTime(mes.year, mes.month + quantidade);
    notifyListeners();
  }

  List<Movimentacao> get doMes => movimentacoes
      .where((m) => m.data.year == mes.year && m.data.month == mes.month)
      .toList();

  double somar(List<Movimentacao> lista, TipoMov tipo) {
    double total = 0;
    for (final m in lista) {
      if (m.tipo == tipo) total += m.valor;
    }
    return total;
  }

  double get receitasMes => somar(doMes, TipoMov.receita);
  double get despesasMes => somar(doMes, TipoMov.despesa);
  double get saldoMes => receitasMes - despesasMes;
  double get saldoTotal =>
      somar(movimentacoes, TipoMov.receita) - somar(movimentacoes, TipoMov.despesa);

  Map<String, double> get gastosPorCategoria {
    final gastos = <String, double>{};
    for (final m in doMes) {
      if (m.tipo == TipoMov.despesa) {
        gastos[m.categoria] = (gastos[m.categoria] ?? 0) + m.valor;
      }
    }
    return gastos;
  }

  String dinheiro(double v) => '$moeda ${formatarNumero(v)}';
}

final app = AppState();
