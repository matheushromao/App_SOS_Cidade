// Testes básicos de fumaça do aplicativo SOS Cidade.

import 'package:flutter_test/flutter_test.dart';

import 'package:sos_cidade/main.dart';
import 'package:sos_cidade/models/chamado.dart';
import 'package:sos_cidade/services/chamado_service.dart';

void main() {
  testWidgets('Dashboard exibe o nome do aplicativo', (tester) async {
    await tester.pumpWidget(const SosCidadeApp());
    // Aguarda o carregamento simulado do serviço.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('SOS Cidade'), findsWidgets);
  });

  test('Service fornece pelo menos 15 chamados mockados', () {
    final service = ChamadoService();
    expect(service.listarChamadosSync().length, greaterThanOrEqualTo(15));
  });

  test('Filtro por status retorna apenas chamados correspondentes', () {
    final service = ChamadoService();
    final todos = service.listarChamadosSync();
    final abertos = service.filtrar(todos, status: StatusChamado.aberto);

    expect(abertos, isNotEmpty);
    expect(
      abertos.every((c) => c.status == StatusChamado.aberto),
      isTrue,
    );
  });

  test('Estatísticas somam corretamente por status', () {
    final service = ChamadoService();
    final todos = service.listarChamadosSync();
    final stats = service.calcularEstatisticas(todos);

    expect(
      stats.abertos + stats.emAndamento + stats.concluidos,
      equals(stats.total),
    );
  });
}
