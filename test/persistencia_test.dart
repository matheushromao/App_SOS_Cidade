// Testa a persistência REAL em SQLite (via sqflite_common_ffi na VM Dart),
// reproduzindo o fluxo do app: semear -> listar -> criar -> listar de novo.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:sos_cidade/models/chamado.dart';
import 'package:sos_cidade/repositories/chamado_repository.dart';
import 'package:sos_cidade/services/chamado_service.dart';
import 'package:sos_cidade/services/database_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Banco limpo a cada teste.
    await databaseFactory.deleteDatabase(DatabaseService.dbName);
    await DatabaseService.instance.fechar();
  });

  test('semear popula o banco e listar retorna os dados', () async {
    final repo = SqliteChamadoRepository(DatabaseService.instance);
    await repo.popularSeVazio();

    final lista = await repo.buscarTodos();
    expect(lista, isNotEmpty);
  });

  test('criar persiste um novo chamado no SQLite', () async {
    final repo = SqliteChamadoRepository(DatabaseService.instance);
    await repo.popularSeVazio();
    final service = ChamadoService(repo);

    final antes = (await service.listar()).length;

    final novo = await service.criar(
      titulo: 'Chamado de teste de persistência',
      descricao: 'Descrição detalhada do problema para o teste.',
      categoria: Categoria.buraco,
      prioridade: Prioridade.alta,
      bairro: 'Centro',
    );

    final depois = await service.listar();
    expect(depois.length, antes + 1);
    expect(await service.obter(novo.id), isNotNull);
  });

  test('título repetido é bloqueado', () async {
    final repo = SqliteChamadoRepository(DatabaseService.instance);
    final service = ChamadoService(repo);

    await service.criar(
      titulo: 'Título único de teste',
      descricao: 'Descrição suficientemente longa.',
      categoria: Categoria.lixo,
      prioridade: Prioridade.baixa,
      bairro: 'Vila Nova',
    );

    expect(
      () => service.criar(
        titulo: 'Título único de teste',
        descricao: 'Outra descrição qualquer.',
        categoria: Categoria.lixo,
        prioridade: Prioridade.baixa,
        bairro: 'Centro',
      ),
      throwsStateError,
    );
  });
}
