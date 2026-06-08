import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/chamado_controller.dart';
import '../models/chamado.dart';
import '../repositories/chamado_repository.dart';
import '../services/chamado_service.dart';
import '../services/database_service.dart';

/// Ponto único de composição (Dependency Injection) da feature de chamados.
///
/// Cada camada declara apenas a sua dependência imediata; o Riverpod resolve a
/// árvore. Trocar uma implementação (ex.: repositório) é alterar UMA linha aqui,
/// sem tocar em Controller, Service ou Views — o que reduz drasticamente o
/// acoplamento e os conflitos de merge entre os membros da equipe.

// --- Infraestrutura --------------------------------------------------------

/// Singleton do banco de dados.
final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService.instance,
);

/// Repositório de chamados.
///
/// PADRÃO: persistência real em SQLite via [SqliteChamadoRepository], para que
/// os dados sobrevivam ao fechamento do app. O banco é semeado uma única vez no
/// bootstrap (`main()` -> `popularSeVazio()`).
///
/// Nos testes este provider é sobrescrito por [InMemoryChamadoRepository]
/// (ver `overrides` em test/widget_test.dart), mantendo-os livres de I/O.
final chamadoRepositoryProvider = Provider<ChamadoRepository>(
  (ref) => SqliteChamadoRepository(ref.watch(databaseServiceProvider)),
);

// --- Domínio ---------------------------------------------------------------

/// Camada de regras de negócio.
final chamadoServiceProvider = Provider<ChamadoService>(
  (ref) => ChamadoService(ref.watch(chamadoRepositoryProvider)),
);

/// Controller com estado (lista, filtros, carregamento). Carrega ao ser criado.
final chamadoControllerProvider =
    StateNotifierProvider<ChamadoController, ChamadoState>(
  (ref) => ChamadoController(ref.watch(chamadoServiceProvider))..carregar(),
);

/// Leitura assíncrona "one-shot" da lista, útil para telas simples que só
/// exibem dados sem precisar do controller (demonstra o uso de FutureProvider).
final chamadosFutureProvider = FutureProvider<List<Chamado>>(
  (ref) => ref.watch(chamadoServiceProvider).listar(),
);

/// Busca um chamado específico por id (usado pela tela de Detalhes).
final chamadoPorIdProvider = FutureProvider.family<Chamado?, String>(
  (ref, id) => ref.watch(chamadoServiceProvider).obter(id),
);

// --- Estado de UI global ---------------------------------------------------

/// Modo de tema (claro/escuro/sistema). Hook para a Pessoa 9 (UI/UX).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
