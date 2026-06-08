import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/chamado_provider.dart';
import 'repositories/chamado_repository.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formatação de datas em pt_BR.
  await initializeDateFormatting('pt_BR', null);

  // Prepara o backend SQLite correto para a plataforma atual e abre o banco.
  DatabaseService.configurarFactory();

  // Semeia a base com dados de exemplo apenas na primeira execução. Depois
  // disso os chamados persistem entre aberturas do app (requisito de SQLite).
  await SqliteChamadoRepository(DatabaseService.instance).popularSeVazio();

  // ProviderScope é a raiz da injeção de dependência do Riverpod.
  runApp(const ProviderScope(child: SosCidadeApp()));
}

/// Widget raiz da aplicação SOS Cidade.
class SosCidadeApp extends ConsumerWidget {
  const SosCidadeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Tema global (Material 3) com suporte a claro/escuro.
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Navegação centralizada.
      initialRoute: AppRoutes.initial,
      onGenerateRoute: AppRoutes.gerarRota,

      // Localização pt_BR.
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
