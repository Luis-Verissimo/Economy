import 'package:flutter/material.dart';

enum TipoMov { receita, despesa }

class Categoria {
  final String nome;
  final IconData icone;
  final Color cor;
  const Categoria(this.nome, this.icone, this.cor);
}

const categoriasDespesa = [
  Categoria('Alimentação', Icons.restaurant, Colors.red),
  Categoria('Transporte', Icons.directions_bus, Colors.blue),
  Categoria('Lazer', Icons.sports_esports, Colors.orange),
  Categoria('Saúde', Icons.favorite, Colors.purple),
  Categoria('Educação', Icons.school, Colors.teal),
  Categoria('Moradia', Icons.home, Colors.blueGrey),
  Categoria('Outros', Icons.more_horiz, Colors.brown),
];

const categoriasReceita = [
  Categoria('Salário', Icons.work, Colors.green),
  Categoria('Bolsa', Icons.school, Colors.lightGreen),
  Categoria('Renda extra', Icons.attach_money, Colors.lime),
  Categoria('Outros', Icons.more_horiz, Colors.grey),
];

List<Categoria> categoriasDo(TipoMov tipo) =>
    tipo == TipoMov.receita ? categoriasReceita : categoriasDespesa;

Categoria buscarCategoria(String nome, TipoMov tipo) {
  final lista = categoriasDo(tipo);
  return lista.firstWhere((c) => c.nome == nome, orElse: () => lista.last);
}

class Movimentacao {
  String id;
  TipoMov tipo;
  String descricao;
  double valor;
  String categoria;
  DateTime data;

  Movimentacao(this.id, this.tipo, this.descricao, this.valor, this.categoria, this.data);

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo.name,
        'descricao': descricao,
        'valor': valor,
        'categoria': categoria,
        'data': data.toIso8601String(),
      };

  static Movimentacao fromJson(Map<String, dynamic> j) => Movimentacao(
        j['id'],
        TipoMov.values.byName(j['tipo']),
        j['descricao'],
        (j['valor'] as num).toDouble(),
        j['categoria'],
        DateTime.parse(j['data']),
      );
}

const meses = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
];

String formatarData(DateTime d) {
  final dia = d.day.toString().padLeft(2, '0');
  final mes = d.month.toString().padLeft(2, '0');
  return '$dia/$mes/${d.year}';
}

// 1234.5 -> "1.234,50"
String formatarNumero(double v) {
  final partes = v.abs().toStringAsFixed(2).split('.');
  final inteiro = partes[0];
  var comPontos = '';
  for (var i = 0; i < inteiro.length; i++) {
    if (i > 0 && (inteiro.length - i) % 3 == 0) comPontos += '.';
    comPontos += inteiro[i];
  }
  return '${v < 0 ? '-' : ''}$comPontos,${partes[1]}';
}

// aceita "1.234,56" ou "1234.56"
double? lerValor(String texto) {
  var t = texto.trim();
  if (t.contains(',')) t = t.replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(t);
}
