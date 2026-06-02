import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chamado.dart'; // Ajuste este caminho conforme a arquitetura da Pessoa 1

class DatabaseHelper {
  static const _databaseName = "sos_cidade.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Tabela adaptada exatamente para o chamado.dart do Ryan
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chamados (
        id TEXT PRIMARY KEY,
        titulo TEXT UNIQUE, 
        descricao TEXT NOT NULL, 
        categoria TEXT NOT NULL,
        prioridade TEXT NOT NULL,
        status TEXT NOT NULL,
        bairro TEXT NOT NULL, 
        dataCriacao TEXT NOT NULL
      )
    ''');
  }

  /// 1. SALVAR CHAMADO
  Future<int> salvarChamado(Chamado chamado) async {
    Database db = await instance.database;
    // O ConflictAlgorithm.abort barra títulos repetidos direto no banco
    return await db.insert(
      'chamados', 
      chamado.toMap(), 
      conflictAlgorithm: ConflictAlgorithm.abort
    );
  }

  /// 2. LISTAR CHAMADOS (Regra: Alta e Crítica no topo)
  Future<List<Chamado>> listarChamados() async {
    Database db = await instance.database;
    
    // O model salva o enum name (critica, alta, media, baixa)
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM chamados
      ORDER BY
        CASE prioridade
          WHEN 'critica' THEN 1
          WHEN 'alta' THEN 2
          WHEN 'media' THEN 3
          WHEN 'baixa' THEN 4
          ELSE 5
        END ASC, dataCriacao DESC
    ''');

    // Converte os Maps do banco de volta para a classe Chamado
    return List.generate(maps.length, (i) {
      return Chamado.fromMap(maps[i]);
    });
  }

  /// 3. ATUALIZAR STATUS (Regra: Concluídos não podem ser editados)
  Future<int> atualizarStatus(String id, StatusChamado novoStatus) async {
    Database db = await instance.database;
    
    List<Map> chamadoAtual = await db.query('chamados', where: 'id = ?', whereArgs: [id]);
    
    // Trava de segurança
    if (chamadoAtual.isNotEmpty && chamadoAtual.first['status'] == StatusChamado.concluido.name) {
      throw Exception('Chamados concluídos não podem ser editados.');
    }

    return await db.update(
      'chamados',
      {'status': novoStatus.name},
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  /// 4. CONTAGEM PARA O DASHBOARD (Totalizadores)[cite: 1]
  Future<Map<String, int>> obterEstatisticasDashboard() async {
    Database db = await instance.database;
    
    int total = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM chamados')) ?? 0;
    int abertos = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM chamados WHERE status = 'aberto'")) ?? 0;
    int emAndamento = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM chamados WHERE status = 'emAndamento'")) ?? 0;
    int concluidos = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM chamados WHERE status = 'concluido'")) ?? 0;
    int criticos = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM chamados WHERE prioridade = 'critica'")) ?? 0;

    return {
      'total': total,
      'abertos': abertos,
      'emAndamento': emAndamento,
      'concluidos': concluidos,
      'criticos': criticos,
    };
  }
}