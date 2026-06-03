import 'package:sqflite_common/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Configuração do backend SQLite para Web.
///
/// Requer o setup único do pacote (copia o worker + sqlite3.wasm para `web/`):
///   dart run sqflite_common_ffi_web:setup
void configurarFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
