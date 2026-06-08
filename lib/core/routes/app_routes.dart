import 'package:flutter/material.dart';

import '../../models/chamado.dart';
import '../../views/chamados/chamado_cadastro_page.dart';
import '../../views/chamados/chamado_detalhes_page.dart';
import '../../views/dashboard/dashboard_page.dart';

/// Navegação centralizada da aplicação.
///
/// Vantagens de concentrar as rotas aqui:
/// - Nomes de rota como constantes (sem strings mágicas espalhadas);
/// - Um único lugar para adicionar/alterar telas, evitando conflitos de merge;
/// - Passagem de argumentos tipada e validada em um só ponto.
///
/// Para adicionar uma tela: declare a constante e trate-a no [gerarRota].
class AppRoutes {
  AppRoutes._();

  static const String dashboard = '/';
  static const String cadastro = '/chamados/novo';
  static const String detalhes = '/chamados/detalhes';

  /// Rota inicial da aplicação.
  static const String initial = dashboard;

  /// Fábrica de rotas usada por `MaterialApp.onGenerateRoute`.
  static Route<dynamic> gerarRota(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return _material(const DashboardPage(), settings);

      case cadastro:
        return _material(const ChamadoCadastroPage(), settings);

      case detalhes:
        // Detalhes exige um Chamado como argumento.
        final args = settings.arguments;
        if (args is Chamado) {
          return _material(ChamadoDetalhesPage(chamado: args), settings);
        }
        return _erro('Argumento inválido para a rota de detalhes.');

      default:
        return _erro('Rota não encontrada: ${settings.name}');
    }
  }

  static MaterialPageRoute<T> _material<T>(Widget page, RouteSettings settings) {
    return MaterialPageRoute<T>(builder: (_) => page, settings: settings);
  }

  static Route<dynamic> _erro(String mensagem) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erro de navegação')),
        body: Center(child: Text(mensagem)),
      ),
    );
  }
}
