// Importar o plugin sqflite registra o `databaseFactory` padrão para
// Android / iOS. O app tem como alvos Web e Mobile; o backend desktop (FFI)
// não é usado, por isso este arquivo depende apenas do plugin `sqflite`.
import 'package:sqflite/sqflite.dart';

/// Configuração do backend SQLite para plataformas nativas (Android / iOS).
void configurarFactory() {
  databaseFactory = databaseFactorySqflitePlugin;
}
