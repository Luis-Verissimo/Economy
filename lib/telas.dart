import 'package:flutter/material.dart';

import 'app_state.dart';
import 'models.dart';
import 'widgets.dart';

// ---------------- Início ----------------

class TelaInicio extends StatelessWidget {
  final VoidCallback verTudo;
  const TelaInicio({super.key, required this.verTudo});

  @override
  Widget build(BuildContext context) {
    final recentes = app.movimentacoes.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        Text('Olá, ${app.nome}!', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 12),
        Card(
          color: Colors.green[700],
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saldo atual', style: TextStyle(color: Colors.white70)),
                Text(app.dinheiro(app.saldoTotal),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        SeletorMes(),
        Row(
          children: [
            Expanded(child: CardValor('Receitas', app.receitasMes, Colors.green)),
            Expanded(child: CardValor('Despesas', app.despesasMes, Colors.red)),
          ],
        ),
        CardValor('Saldo do mês', app.saldoMes, app.saldoMes >= 0 ? Colors.green : Colors.red),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Movimentações recentes', style: TextStyle(fontSize: 16)),
            TextButton(onPressed: verTudo, child: const Text('Ver tudo')),
          ],
        ),
        if (recentes.isEmpty) const Vazio('Nenhuma movimentação ainda. Toque em + para adicionar.'),
        for (final m in recentes) ItemMovimentacao(m),
      ],
    );
  }
}

// ---------------- Cadastro / edição ----------------

class TelaCadastro extends StatefulWidget {
  final Movimentacao? editar;
  const TelaCadastro({super.key, this.editar});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final descricao = TextEditingController();
  final valor = TextEditingController();
  TipoMov tipo = TipoMov.despesa;
  String categoria = categoriasDespesa.first.nome;
  DateTime data = DateTime.now();

  @override
  void initState() {
    super.initState();
    final m = widget.editar;
    if (m != null) {
      descricao.text = m.descricao;
      valor.text = m.valor.toStringAsFixed(2).replaceAll('.', ',');
      tipo = m.tipo;
      categoria = m.categoria;
      data = m.data;
    }
  }

  void mostrarAviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void salvar() {
    final numero = lerValor(valor.text);
    if (descricao.text.trim().isEmpty) return mostrarAviso('Informe a descrição');
    if (numero == null || numero <= 0) return mostrarAviso('Informe um valor válido');

    final id = widget.editar?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    app.salvarMovimentacao(
        Movimentacao(id, tipo, descricao.text.trim(), numero, categoria, data));
    Navigator.pop(context);
  }

  void excluir() async {
    if (await confirmar(context, 'Excluir esta movimentação?')) {
      app.excluirMovimentacao(widget.editar!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  void escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (escolhida != null) setState(() => data = escolhida);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editar == null ? 'Nova movimentação' : 'Editar movimentação'),
        actions: [
          if (widget.editar != null)
            IconButton(onPressed: excluir, icon: const Icon(Icons.delete)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<TipoMov>(
            segments: const [
              ButtonSegment(value: TipoMov.receita, label: Text('Receita')),
              ButtonSegment(value: TipoMov.despesa, label: Text('Despesa')),
            ],
            selected: {tipo},
            onSelectionChanged: (s) => setState(() {
              tipo = s.first;
              categoria = categoriasDo(tipo).first.nome;
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descricao,
            decoration: const InputDecoration(labelText: 'Descrição'),
          ),
          TextField(
            controller: valor,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Valor', prefixText: '${app.moeda} '),
          ),
          const SizedBox(height: 12),
          DropdownButton<String>(
            value: categoria,
            isExpanded: true,
            items: [
              for (final c in categoriasDo(tipo))
                DropdownMenuItem(
                  value: c.nome,
                  child: Row(children: [
                    Icon(c.icone, color: c.cor),
                    const SizedBox(width: 8),
                    Text(c.nome),
                  ]),
                ),
            ],
            onChanged: (v) => setState(() => categoria = v!),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text('Data: ${formatarData(data)}'),
            onTap: escolherData,
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: salvar, child: const Text('Salvar')),
        ],
      ),
    );
  }
}

// ---------------- Histórico ----------------

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  TipoMov? filtro; // null mostra todas

  Widget botaoFiltro(String texto, TipoMov? valor) {
    return ChoiceChip(
      label: Text(texto),
      selected: filtro == valor,
      onSelected: (_) => setState(() => filtro = valor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = app.doMes.where((m) => filtro == null || m.tipo == filtro).toList();

    return Column(
      children: [
        SeletorMes(),
        Wrap(
          spacing: 8,
          children: [
            botaoFiltro('Todas', null),
            botaoFiltro('Receitas', TipoMov.receita),
            botaoFiltro('Despesas', TipoMov.despesa),
          ],
        ),
        const Text('Toque para editar, arraste para excluir',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        Expanded(
          child: lista.isEmpty
              ? const Vazio('Nenhuma movimentação neste mês.')
              : ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [for (final m in lista) ItemMovimentacao(m, editavel: true)],
                ),
        ),
      ],
    );
  }
}

// ---------------- Análise de gastos ----------------

class TelaAnalise extends StatelessWidget {
  const TelaAnalise({super.key});

  @override
  Widget build(BuildContext context) {
    final gastos = app.gastosPorCategoria.entries.toList();
    gastos.sort((a, b) => b.value.compareTo(a.value));
    final total = app.despesasMes;

    if (gastos.isEmpty) {
      return Column(children: [SeletorMes(), const Vazio('Sem despesas neste mês.')]);
    }

    String porcentagem(double v) => '${(v / total * 100).toStringAsFixed(1)}%';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      children: [
        SeletorMes(),
        Center(child: Text('Total gasto: ${app.dinheiro(total)}')),
        const SizedBox(height: 12),
        Center(
          child: Grafico({
            for (final g in gastos) buscarCategoria(g.key, TipoMov.despesa).cor: g.value,
          }),
        ),
        const SizedBox(height: 12),
        for (final g in gastos)
          ListTile(
            leading: Icon(buscarCategoria(g.key, TipoMov.despesa).icone,
                color: buscarCategoria(g.key, TipoMov.despesa).cor),
            title: Text(g.key),
            subtitle: LinearProgressIndicator(
              value: g.value / total,
              color: buscarCategoria(g.key, TipoMov.despesa).cor,
            ),
            trailing: Text('${app.dinheiro(g.value)}\n${porcentagem(g.value)}',
                textAlign: TextAlign.right),
          ),
        const SizedBox(height: 12),
        Text('Seu maior gasto é com ${gastos.first.key} (${porcentagem(gastos.first.value)} do total).'),
      ],
    );
  }
}

// ---------------- Metas e orçamentos ----------------

class TelaMetas extends StatelessWidget {
  const TelaMetas({super.key});

  // valor vazio remove a meta ou o limite
  Future<double?> pedirValor(BuildContext context, String titulo, double atual) async {
    final inicial = atual > 0 ? atual.toStringAsFixed(2).replaceAll('.', ',') : '';
    final texto = await pedirTexto(context, titulo, inicial, dinheiro: true);
    if (texto == null) return null;
    return lerValor(texto) ?? 0;
  }

  void editarMeta(BuildContext context) async {
    final v = await pedirValor(context, 'Meta de economia', app.meta);
    if (v == null) return;
    app.meta = v;
    app.salvar();
  }

  void editarLimite(BuildContext context, String categoria) async {
    final v = await pedirValor(context, 'Limite: $categoria', app.limites[categoria] ?? 0);
    if (v == null) return;
    if (v > 0) {
      app.limites[categoria] = v;
    } else {
      app.limites.remove(categoria);
    }
    app.salvar();
  }

  @override
  Widget build(BuildContext context) {
    final economizado = app.saldoMes;
    final progresso = app.meta > 0 ? (economizado / app.meta).clamp(0.0, 1.0) : 0.0;
    final gastos = app.gastosPorCategoria;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      children: [
        SeletorMes(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Meta de economia mensal'),
          subtitle: Text(app.meta <= 0
              ? 'Nenhuma meta definida.'
              : 'Economizado: ${app.dinheiro(economizado)} de ${app.dinheiro(app.meta)}'),
          trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => editarMeta(context)),
        ),
        if (app.meta > 0) LinearProgressIndicator(value: progresso, minHeight: 10),
        if (app.meta > 0 && progresso >= 1) const Text('Meta atingida!'),
        const SizedBox(height: 20),
        const Text('Limites de gastos por categoria', style: TextStyle(fontSize: 16)),
        for (final cat in categoriasDespesa)
          itemLimite(context, cat, gastos[cat.nome] ?? 0, app.limites[cat.nome]),
      ],
    );
  }

  Widget itemLimite(BuildContext context, Categoria cat, double gasto, double? limite) {
    Widget detalhe = Text('Sem limite - gasto ${app.dinheiro(gasto)}');

    if (limite != null) {
      final uso = gasto / limite;
      final cor = uso >= 1 ? Colors.red : (uso >= 0.8 ? Colors.orange : Colors.green);
      detalhe = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: uso.clamp(0.0, 1.0), color: cor),
          Text('${app.dinheiro(gasto)} de ${app.dinheiro(limite)}'
              '${uso >= 1 ? ' - limite excedido!' : ''}'),
        ],
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(cat.icone, color: cat.cor),
      title: Text(cat.nome),
      subtitle: detalhe,
      trailing: const Icon(Icons.edit, size: 18),
      onTap: () => editarLimite(context, cat.nome),
    );
  }
}

// ---------------- Configurações ----------------

class TelaConfiguracoes extends StatelessWidget {
  const TelaConfiguracoes({super.key});

  void editarNome(BuildContext context) async {
    final texto = await pedirTexto(context, 'Seu nome', app.nome);
    if (texto != null && texto.trim().isNotEmpty) {
      app.nome = texto.trim();
      app.salvar();
    }
  }

  void limpar(BuildContext context) async {
    if (await confirmar(context, 'Apagar todas as movimentações, metas e limites?')) {
      app.limparTudo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Nome'),
              subtitle: Text(app.nome),
              onTap: () => editarNome(context),
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Moeda'),
              trailing: DropdownButton<String>(
                value: app.moeda,
                items: [
                  for (final m in ['R\$', 'US\$', '€', '£'])
                    DropdownMenuItem(value: m, child: Text(m)),
                ],
                onChanged: (v) {
                  app.moeda = v!;
                  app.salvar();
                },
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Tema escuro'),
              value: app.temaEscuro,
              onChanged: (v) {
                app.temaEscuro = v;
                app.salvar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Limpar todos os dados'),
              onTap: () => limpar(context),
            ),
          ],
        ),
      ),
    );
  }
}
