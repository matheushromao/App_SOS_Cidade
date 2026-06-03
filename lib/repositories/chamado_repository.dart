import '../core/utils/dados_mock.dart';
import '../models/chamado.dart';
import '../services/database_service.dart';

/// Contrato de acesso a dados de [Chamado].
///
/// A camada de Service depende desta abstração, e não de uma implementação
/// concreta. Isso permite:
/// - Trocar SQLite por API REST/Firebase no futuro sem tocar na UI;
/// - Usar [InMemoryChamadoRepository] em testes e no início do projeto,
///   enquanto a persistência (Pessoa 3) ainda está em desenvolvimento.
abstract interface class ChamadoRepository {
  Future<List<Chamado>> buscarTodos();
  Future<Chamado?> buscarPorId(String id);
  Future<void> inserir(Chamado chamado);
  Future<void> atualizar(Chamado chamado);
  Future<void> remover(String id);
}

/// Implementação baseada em SQLite (via [DatabaseService]).
///
/// Pronta como referência para a Pessoa 3. As queries básicas já estão aqui;
/// otimizações e novas consultas (ex.: filtros no SQL) podem ser adicionadas
/// sem afetar as demais camadas.
class SqliteChamadoRepository implements ChamadoRepository {
  SqliteChamadoRepository(this._dbService);

  final DatabaseService _dbService;
  static const String _tabela = DatabaseService.tabelaChamados;

  /// Popula o banco com dados de exemplo apenas se a tabela estiver vazia.
  Future<void> popularSeVazio() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM $_tabela');
    final count = (result.first['total'] as int?) ?? 0;
    if (count > 0) return;

    final batch = db.batch();
    for (final chamado in DadosMock.gerar()) {
      batch.insert(_tabela, chamado.toMap());
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Chamado>> buscarTodos() async {
    final db = await _dbService.database;
    final rows = await db.query(_tabela, orderBy: 'dataCriacao DESC');
    return rows.map(Chamado.fromMap).toList();
  }

  @override
  Future<Chamado?> buscarPorId(String id) async {
    final db = await _dbService.database;
    final rows = await db.query(
      _tabela,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Chamado.fromMap(rows.first);
  }

  @override
  Future<void> inserir(Chamado chamado) async {
    final db = await _dbService.database;
    await db.insert(_tabela, chamado.toMap());
  }

  @override
  Future<void> atualizar(Chamado chamado) async {
    final db = await _dbService.database;
    await db.update(
      _tabela,
      chamado.toMap(),
      where: 'id = ?',
      whereArgs: [chamado.id],
    );
  }

  @override
  Future<void> remover(String id) async {
    final db = await _dbService.database;
    await db.delete(_tabela, where: 'id = ?', whereArgs: [id]);
  }
}

/// Implementação em memória — sem banco, sem plataforma.
///
/// Funciona imediatamente em qualquer plataforma (inclusive Web sem setup) e
/// nos testes. Ideal para a equipe de UI trabalhar em paralelo à Pessoa 3.
class InMemoryChamadoRepository implements ChamadoRepository {
  InMemoryChamadoRepository({bool popular = true}) {
    if (popular) {
      _itens.addAll(DadosMock.gerar());
    }
  }

  final List<Chamado> _itens = [];

  @override
  Future<List<Chamado>> buscarTodos() async {
    final lista = [..._itens]
      ..sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
    return lista;
  }

  @override
  Future<Chamado?> buscarPorId(String id) async {
    for (final c in _itens) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> inserir(Chamado chamado) async => _itens.add(chamado);

  @override
  Future<void> atualizar(Chamado chamado) async {
    final i = _itens.indexWhere((c) => c.id == chamado.id);
    if (i != -1) _itens[i] = chamado;
  }

  @override
  Future<void> remover(String id) async =>
      _itens.removeWhere((c) => c.id == id);
}
