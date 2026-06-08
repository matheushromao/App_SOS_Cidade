# SOS Cidade — Guia de Arquitetura

Fundação do projeto (MVC + Repository + Service + Riverpod + SQLite).
Leia antes de começar a desenvolver sua parte.

## Fluxo de dependências (uma única direção)

```
View (Riverpod)  →  Controller (StateNotifier)  →  Service (regras)  →  Repository (abstração)  →  DatabaseService (SQLite)
        ↑                                                                         ↑
        └────────────── Providers (Injeção de Dependência) ──────────────────────┘
```

Regra de ouro: **uma camada só conhece a de baixo, e apenas pela sua abstração.**
A View nunca acessa Repository/SQLite diretamente.

## Camadas

| Camada | Pasta | Responsabilidade |
|---|---|---|
| **Model** | `models/` | Dados puros + serialização (`toMap/fromMap/toJson/fromJson`). Sem Flutter. |
| **View** | `views/` | UI. Observa o estado e dispara ações. Sem regra de negócio. |
| **Controller** | `controllers/` | Mantém o estado da tela e orquestra ações (o "C" do MVC). |
| **Service** | `services/` | Regras de negócio: validação, filtros, estatísticas, IDs. |
| **Repository** | `repositories/` | Abstração de acesso a dados (SQLite hoje, API amanhã). |
| **DatabaseService** | `services/database_service.dart` | Conexão e schema SQLite (Singleton). |
| **Providers** | `providers/` | Injeção de dependência (Riverpod) — monta toda a árvore. |
| **Widgets** | `widgets/` | Componentes visuais reutilizáveis, sem estado de domínio. |

## Divisão da equipe (trabalho em paralelo sem conflito)

| Pessoa | Frente | Toca principalmente em |
|---|---|---|
| 2 | Models e regras | `models/`, `services/chamado_service.dart` |
| 3 | SQLite/persistência | `services/database_service.dart`, `repositories/` |
| 4 | Dashboard | `views/dashboard/` |
| 5 | Lista de chamados | `widgets/lists/`, `widgets/cards/` |
| 6 | Cadastro | `views/chamados/chamado_cadastro_page.dart` |
| 7 | Detalhes/edição | `views/chamados/chamado_detalhes_page.dart` |
| 8 | Busca e filtros | `views/chamados/chamados_filter_bar.dart`, filtros no Service |
| 9 | UI/UX e responsividade | `core/theme/`, `core/utils/responsive.dart`, `views/shared/` |
| 10 | Extras | novos providers/serviços isolados |

## Persistência: in-memory hoje, SQLite quando pronto

Por padrão o app roda com `InMemoryChamadoRepository` (funciona em todas as
plataformas, inclusive Web, sem setup). A estrutura SQLite já está pronta
(`DatabaseService` + `SqliteChamadoRepository`).

**Para ativar o SQLite** (Pessoa 3): em `providers/chamado_provider.dart`,
troque o corpo de `chamadoRepositoryProvider` para usar
`SqliteChamadoRepository(ref.watch(databaseServiceProvider))` e chame
`repo.popularSeVazio()` no bootstrap. Nenhuma outra camada muda.

**SQLite na Web** exige um setup único (copia o worker + `sqlite3.wasm`):

```bash
dart run sqflite_common_ffi_web:setup
```

## Comandos

```bash
flutter pub get
flutter run -d chrome      # Web
flutter run                # Android/iOS
flutter analyze            # estática
flutter test               # testes (usam repositório em memória)
```
