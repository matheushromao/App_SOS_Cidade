# 🏙️ SOS Cidade

Aplicativo Flutter para **registro e acompanhamento de ocorrências urbanas**
(buracos na via, falta de iluminação, vazamentos, semáforos quebrados, lixo,
árvores caídas, enchentes, acidentes). Pensado para uma central de atendimento
da prefeitura priorizar e resolver chamados da população.

> Projeto acadêmico desenvolvido em equipe e integrado em uma arquitetura única
> **MVC + Repository + Service** com **Riverpod** e **SQLite**.

---

## ✨ Funcionalidades

- **Dashboard** com nome do app, **data e hora ao vivo**, total de chamados e
  cards de **Abertos · Em Andamento · Concluídos · Críticos**.
- **Cadastro** de chamados com título, descrição, categoria, prioridade, status,
  bairro, responsável e data.
- **Lista** de chamados com ícone, título, categoria, prioridade, status, bairro
  e data; toque abre os **Detalhes** (com tempo decorrido calculado).
- **Busca** (título/descrição/bairro) e **filtros** por categoria, status e
  prioridade.
- **Dark mode** (alternável no cabeçalho).
- **Alerta** automático quando há mais de 5 chamados críticos.
- **Persistência em SQLite** — os dados permanecem após fechar o app.

### Regras de negócio
- Título não pode se repetir.
- Descrição e bairro não podem ficar vazios.
- Chamados concluídos não podem ser editados.
- Chamados críticos e altos aparecem primeiro na lista.
- Tempo do chamado calculado automaticamente.

---

## 🛠️ Tecnologias

| Camada | Tecnologia |
|---|---|
| UI | Flutter · Material Design 3 |
| Estado / DI | Riverpod (`flutter_riverpod`) |
| Persistência | SQLite (`sqflite` + `sqflite_common_ffi` / `_web`) |
| Datas (pt-BR) | `intl` |

---

## 🏗️ Arquitetura

```
View (Widgets)  →  Controller (StateNotifier)  →  Service (regras)  →  Repository  →  SQLite
        └──────────── Riverpod (injeção de dependência) ────────────┘
```

A View nunca acessa o banco diretamente. Trocar a fonte de dados (SQLite ↔
memória) é alterar **uma linha** em `lib/providers/chamado_provider.dart`.

```
lib/
├── models/        # Chamado + enums (puro, sem Flutter)
├── controllers/   # ChamadoController (estado da tela)
├── services/      # ChamadoService (regras) · DatabaseService (conexão)
├── repositories/  # Abstração + Sqlite/InMemory ChamadoRepository
├── providers/     # Composição Riverpod
├── views/         # Dashboard · Cadastro · Detalhes
├── widgets/       # Cards, header, filtros, busca...
└── core/          # Tema, rotas, constantes, utils, dados semente
```

Mais detalhes em [`ARQUITETURA.md`](ARQUITETURA.md) e
[`VISAO_GERAL.md`](VISAO_GERAL.md).

---

## 🚀 Como executar

```bash
flutter pub get
```

### Mobile / Desktop
```bash
flutter run            # Android, iOS, Windows, macOS ou Linux
```

### Web (passo extra obrigatório, só uma vez)
O backend SQLite na web precisa do worker e do `sqlite3.wasm` copiados para
`web/`:

```bash
dart run sqflite_common_ffi_web:setup
flutter run -d chrome
```

> ⚠️ Sem esse setup o banco não abre na web. O app continua iniciando (não fica
> em branco) e exibe um estado de erro com **"Tentar novamente"**.

---

## ✅ Testes

```bash
flutter test       # testes de model, service e UI
flutter analyze    # análise estática
```

Os testes injetam o repositório **em memória** (sem SQLite), garantindo
execução rápida e isolada.

---

## 📦 Persistência

Os chamados ficam em `sos_cidade.db`. A base é semeada com dados de exemplo
apenas na primeira execução (`main()` → `popularSeVazio()`); depois disso os
dados persistem entre aberturas do app.
