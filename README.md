# EconoMY

Aplicativo de controle de finanças pessoais feito em Flutter para a disciplina de Desenvolvimento Mobile (UNIPE).

## Funcionalidades
- Cadastro, edição e exclusão de receitas e despesas
- Saldo atual e resumo do mês
- Histórico com filtro por tipo
- Análise de gastos por categoria
- Meta de economia mensal e limite de gastos por categoria
- Configurações: nome, moeda, tema escuro e limpar dados

## Estrutura
- `lib/main.dart` - início do app, tema e menu de abas
- `lib/models.dart` - classes de dados e formatação
- `lib/app_state.dart` - dados do app e salvamento (shared_preferences)
- `lib/widgets.dart` - componentes usados em várias telas
- `lib/telas.dart` - telas do app

## Como rodar
```
flutter pub get
flutter run
```

## Grupo
- Davi Farias Madruga
- José Ricardo Souza da Silva
- Luís Gabriel Veríssimo Werlang Leite
