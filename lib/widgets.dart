import 'dart:math';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'models.dart';
import 'telas.dart';

void abrir(BuildContext context, Widget tela) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => tela));
}

Future<bool> confirmar(BuildContext context, String mensagem) async {
  final resposta = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      content: Text(mensagem),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar')),
        TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Confirmar')),
      ],
    ),
  );
  return resposta == true;
}

// janela com um campo de texto; retorna o texto ou null se cancelar
Future<String?> pedirTexto(BuildContext context, String titulo, String inicial,
    {bool dinheiro = false}) {
  final controle = TextEditingController(text: inicial);
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(titulo),
      content: TextField(
        controller: controle,
        autofocus: true,
        keyboardType: dinheiro ? TextInputType.number : TextInputType.text,
        decoration:
            InputDecoration(prefixText: dinheiro ? '${app.moeda} ' : null),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
        TextButton(
            onPressed: () => Navigator.pop(c, controle.text),
            child: const Text('Salvar')),
      ],
    ),
  );
}

class SeletorMes extends StatelessWidget {
  const SeletorMes({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () => app.mudarMes(-1),
            icon: const Icon(Icons.chevron_left)),
        Text('${meses[app.mes.month - 1]} de ${app.mes.year}'),
        IconButton(
            onPressed: () => app.mudarMes(1),
            icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}

class CardValor extends StatelessWidget {
  final String titulo;
  final double valor;
  final Color cor;

  const CardValor(this.titulo, this.valor, this.cor, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo),
            Text(app.dinheiro(valor),
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: cor)),
          ],
        ),
      ),
    );
  }
}

class ItemMovimentacao extends StatelessWidget {
  final Movimentacao m;
  final bool editavel;

  const ItemMovimentacao(this.m, {super.key, this.editavel = false});

  @override
  Widget build(BuildContext context) {
    final cat = buscarCategoria(m.categoria, m.tipo);
    final receita = m.tipo == TipoMov.receita;

    final item = ListTile(
      leading: Icon(cat.icone, color: cat.cor),
      title: Text(m.descricao),
      subtitle: Text('${m.categoria} - ${formatarData(m.data)}'),
      trailing: Text(
        (receita ? '+ ' : '- ') + app.dinheiro(m.valor),
        style: TextStyle(color: receita ? Colors.green : Colors.red),
      ),
      onTap: editavel ? () => abrir(context, TelaCadastro(editar: m)) : null,
    );

    if (!editavel) return item;

    // arrastar para a esquerda exclui
    return Dismissible(
      key: Key(m.id),
      direction: DismissDirection.endToStart,
      background: Container(color: Colors.red),
      confirmDismiss: (_) => confirmar(context, 'Excluir "${m.descricao}"?'),
      onDismissed: (_) => app.excluirMovimentacao(m.id),
      child: item,
    );
  }
}

class Vazio extends StatelessWidget {
  final String texto;
  const Vazio(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Text(texto,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey)),
    );
  }
}

// gráfico de pizza: cada categoria vira um arco
class Grafico extends StatelessWidget {
  final Map<Color, double> fatias;
  const Grafico(this.fatias, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(180, 180), painter: _Pintor(fatias));
  }
}

class _Pintor extends CustomPainter {
  final Map<Color, double> fatias;
  _Pintor(this.fatias);

  @override
  void paint(Canvas canvas, Size size) {
    final total = fatias.values.fold(0.0, (a, b) => a + b);
    final area = Rect.fromLTWH(20, 20, size.width - 40, size.height - 40);
    var inicio = -pi / 2;

    fatias.forEach((cor, valor) {
      final angulo = valor / total * 2 * pi;
      final pincel = Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40;
      canvas.drawArc(area, inicio, angulo, false, pincel);
      inicio += angulo;
    });
  }

  @override
  bool shouldRepaint(_Pintor old) => true;
}
