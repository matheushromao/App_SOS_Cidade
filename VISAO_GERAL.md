# SOS Cidade — Documentação de Visão Geral

Aplicativo Flutter para registro e acompanhamento de ocorrências urbanas
(buracos, iluminação, vazamentos, etc.) por uma prefeitura/central de
atendimento.

## Tecnologias
- **Flutter / Dart** · **Material Design 3** (tema claro/escuro)
- **Riverpod** (gerência de estado + injeção de dependência)
- **SQLite** multiplataforma (`sqflite` no mobile, `sqflite_common_ffi` no
  desktop/testes, `sqflite_common_ffi_web` na web)
- **intl** (datas/horas em `pt_BR`)

## Arquitetura (MVC + Repository + Service)

```
View (Widgets)            →  observa estado e dispara ações
   │ Riverpod (providers)
   ▼
Controller (StateNotifier) →  mantém o estado da tela (lista, filtros, stats)
   ▼
Service (regras de negócio) →  validações, ordenação, estatísticas
   ▼
Repository (abstração)     →  SQLite (produção) / InMemory (testes)
   ▼
DatabaseService            →  conexão e schema do SQLite
```

A View **nunca** fala direto com o banco. Trocar a fonte de dados é alterar
**uma linha** em `lib/providers/chamado_provider.dart`.

### Mapa de pastas
| Pasta | Responsabilidade |
|---|---|
| `models/` | `Chamado` + enums (puro, sem Flutter) |
| `controllers/` | `ChamadoController` (estado da UI) |
| `services/` | `ChamadoService` (regras), `DatabaseService` (conexão) |
| `repositories/` | Abstração + `SqliteChamadoRepository` / `InMemoryChamadoRepository` |
| `providers/` | Composição Riverpod (DI) |
| `views/` | Telas: Dashboard, Cadastro, Detalhes |
| `widgets/` | Componentes reutilizáveis (cards, header, filtros, busca) |
| `core/` | Tema, rotas, constantes, utilitários, dados semente |

## Funcionalidades

### Dashboard
Nome do app, **data e hora ao vivo** (atualiza a cada segundo), total de
chamados, 4 cards (Abertos · Em Andamento · Concluídos · Críticos), busca,
filtros (categoria/status/prioridade), alerta de críticos e lista de chamados.

### Cadastro
Formulário com título, descrição, categoria, prioridade, **status**, bairro,
responsável (opcional) e **data** (date picker). Validação em tela + regras no
Service.

### Lista / Detalhes
Cada card mostra ícone, título, categoria, prioridade, status, bairro e data.
A tela de detalhes exibe protocolo, todas as informações e o **tempo decorrido**
(cálculo automático).

## Regras de negócio (no `ChamadoService`)
| Regra | Onde |
|---|---|
| Título não pode repetir | `_garantirTituloUnico` |
| Descrição não pode ser vazia | `_validar` |
| Bairro não pode ser vazio | `_validar` |
| Chamados concluídos não podem ser editados | `atualizar` (lança `StateError`) |
| Críticos e altos aparecem primeiro | `_ordenar` (peso por prioridade) |
| Alerta com mais de 5 críticos | widget `AlertaCriticos` |
| Tempo do chamado calculado automaticamente | `DateFormatter.relative` |

## Persistência
Os dados ficam em `sos_cidade.db` (SQLite). A base é semeada uma única vez na
primeira execução (`main()` → `popularSeVazio()`); depois disso os chamados
**permanecem após fechar o app**.

## Como rodar
```bash
flutter pub get
flutter run            # Windows/Android/iOS/desktop
# Para Web (uma vez): dart run sqflite_common_ffi_web:setup
flutter test           # 9 testes (model, service, UI)
```

## Funcionalidades extras
- ✅ Busca textual (título, descrição, bairro)
- ✅ Filtros por categoria, status e prioridade
- ✅ **Dark mode** (toggle no cabeçalho do Dashboard)
- ✅ Alerta de situação crítica
- ⬜ Ranking de bairros · upload de imagem · favoritos · notificações (não solicitados como obrigatórios — não implementados)
