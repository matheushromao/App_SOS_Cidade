import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
// sqflite_common é Dart puro (web-safe). A seleção do backend concreto
// (mobile/desktop/web) é feita por import condicional, mantendo este arquivo
// compilável em TODAS as plataformas.
import 'package:sqflite_common/sqflite.dart';

import 'db/factory_config_io.dart'
    if (dart.library.html) 'db/factory_config_web.dart' as db_factory;

/// Serviço de acesso ao banco SQLite.
///
/// Responsabilidades:
/// - Selecionar o `databaseFactory` correto por plataforma (mobile/desktop/web);
/// - Abrir/criar o banco de forma preguiçosa (lazy) e mantê-lo como Singleton;
/// - Versionar o schema e criar as tabelas.
///
/// NÃO contém regra de negócio nem queries de domínio — isso é papel do
/// [ChamadoRepository]. Aqui ficam apenas a conexão e o schema.
class DatabaseService {
  DatabaseService._();

  /// Instância única (Singleton) compartilhada por toda a aplicação.
  static final DatabaseService instance = DatabaseService._();

  static const String dbName = 'sos_cidade.db';
  static const int dbVersion = 1;

  /// Nome da tabela de chamados (exposto para os repositórios).
  static const String tabelaChamados = 'chamados';

  Database? _db;

  /// Ajusta o `databaseFactory` conforme a plataforma.
  /// Deve ser chamado uma vez no `main()` antes de abrir o banco.
  static void configurarFactory() => db_factory.configurarFactory();

  /// Acesso ao banco já aberto (abre na primeira chamada).
  Future<Database> get database async => _db ??= await _abrir();

  Future<Database> _abrir() async {
    final String path = kIsWeb
        ? dbName
        : p.join(await databaseFactory.getDatabasesPath(), dbName);

    return databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: dbVersion,
        onCreate: _onCreate,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      ),
    );
  }

  /// Criação do schema na primeira execução.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tabelaChamados (
        id          TEXT PRIMARY KEY,
        titulo      TEXT NOT NULL,
        descricao   TEXT NOT NULL,
        categoria   TEXT NOT NULL,
        prioridade  TEXT NOT NULL,
        status      TEXT NOT NULL,
        bairro      TEXT NOT NULL,
        responsavel TEXT,
        dataCriacao TEXT NOT NULL
      )
    ''');

    // Índices úteis para as telas de busca/filtros (Pessoa 8).
    await db.execute(
      'CREATE INDEX idx_chamados_status ON $tabelaChamados (status)',
    );
    await db.execute(
      'CREATE INDEX idx_chamados_categoria ON $tabelaChamados (categoria)',
    );
  }

  /// Fecha a conexão (útil em testes ou logout).
  Future<void> fechar() async {
    await _db?.close();
    _db = null;
  }
}
