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
- **Persistência em SQLite** — no mobile (Android/iOS) os dados permanecem após
  fechar o app. Na web há um *fallback* automático em memória caso o backend
  SQLite do navegador não esteja disponível (ver seção Persistência).

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
| Persistência | SQLite (`sqflite` no mobile, `sqflite_common_ffi_web` na web) |
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

### Mobile (recomendado — persistência SQLite completa)
```bash
flutter run            # Android ou iOS
```

### Web
```bash
flutter run -d chrome
```

O app abre normalmente na web e exibe os dados (não fica em branco). O backend
SQLite do navegador (`sqflite_common_ffi_web`) usa um *web worker* que depende
de isolamento cross-origin; quando ele não está disponível, o app cai
automaticamente para um repositório **em memória** — totalmente funcional na
sessão, mas sem persistir após recarregar. Para a persistência real, use o
**mobile**.

---

## ✅ Testes

```bash
flutter test       # testes de model, service e UI (repositório em memória)
flutter analyze    # análise estática
```

> **Nota (Windows + Flutter 3.41.9):** o pacote `sqlite3` está fixado na linha
> **2.x** (`pubspec.yaml`) de propósito. A linha 3.x usa o mecanismo
> experimental de *native assets*, que dispara um bug do Flutter ao copiar
> `sqlite3.dll` durante o `flutter test` no Windows (`PathExistsException`,
> errno 183). Fixando em 2.x, tanto o build Web quanto os testes funcionam.

---

## 📦 Persistência

A camada de dados é abstraída por `ChamadoRepository` (ver `repositories/`):

- **Mobile (Android/iOS):** `SqliteChamadoRepository` sobre o plugin nativo
  `sqflite`. Os chamados ficam em `sos_cidade.db` e **permanecem após fechar o
  app**.
- **Web:** tenta o SQLite via `sqflite_common_ffi_web`; se indisponível, usa
  `InMemoryChamadoRepository` (fallback definido em `main.dart`).

A base é semeada com dados de exemplo apenas na primeira execução
(`main()` → `popularSeVazio()`). Trocar a fonte de dados é alterar **uma linha**
em `lib/providers/chamado_provider.dart`.
