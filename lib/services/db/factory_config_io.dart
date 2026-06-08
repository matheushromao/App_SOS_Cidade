import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
// Importar o plugin sqflite registra o `databaseFactory` padrão no mobile.
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Configuração do backend SQLite para plataformas nativas (mobile/desktop).
///
/// - Android / iOS: usam o `databaseFactory` padrão do plugin sqflite.
/// - Windows / Linux / macOS (e testes na VM Dart): usam o backend FFI.
void configurarFactory() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      break;
    default:
      // Android / iOS usam o factory do plugin sqflite.
      databaseFactory = databaseFactorySqflitePlugin;
  }
}
