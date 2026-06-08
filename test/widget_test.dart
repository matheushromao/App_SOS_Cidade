// Testes da fundação do SOS Cidade.
//
// As camadas são testadas de forma isolada graças à injeção de dependência:
// o Service recebe um InMemoryChamadoRepository, sem necessidade de SQLite.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sos_cidade/main.dart';
import 'package:sos_cidade/models/chamado.dart';
import 'package:sos_cidade/providers/chamado_provider.dart';
import 'package:sos_cidade/repositories/chamado_repository.dart';
import 'package:sos_cidade/services/chamado_service.dart';

void main() {
  group('Model Chamado', () {
    final chamado = Chamado(
      id: 'abc',
      titulo: 'Buraco grande',
      descricao: 'Descrição com mais de dez caracteres.',
      categoria: Categoria.buraco,
      prioridade: Prioridade.alta,
      status: StatusChamado.aberto,
      bairro: 'Centro',
      responsavel: 'Obras',
      dataCriacao: DateTime(2026, 6, 2, 10, 30),
    );

    test('round-trip toMap/fromMap preserva os dados', () {
      final copia = Chamado.fromMap(chamado.toMap());
      expect(copia.id, chamado.id);
      expect(copia.categoria, Categoria.buraco);
      expect(copia.responsavel, 'Obras');
      expect(copia.dataCriacao, chamado.dataCriacao);
    });

    test('round-trip toJson/fromJson preserva os dados', () {
      final copia = Chamado.fromJson(chamado.toJson());
      expect(copia, equals(chamado)); // igualdade por id
      expect(copia.status, StatusChamado.aberto);
    });

    test('copyWith altera apenas o campo informado', () {
      final atualizado = chamado.copyWith(status: StatusChamado.concluido);
      expect(atualizado.status, StatusChamado.concluido);
      expect(atualizado.titulo, chamado.titulo);
    });
  });

  group('ChamadoService', () {
    late ChamadoService service;

    setUp(() {
      service = ChamadoService(InMemoryChamadoRepository());
    });

    test('listar retorna a massa de dados semente', () async {
      final lista = await service.listar();
      expect(lista, isNotEmpty);
    });

    test('filtrar por status retorna apenas correspondentes', () async {
      final todos = await service.listar();
      final abertos = service.filtrar(
        todos,
        const FiltroChamado(status: StatusChamado.aberto),
      );
      expect(abertos, isNotEmpty);
      expect(abertos.every((c) => c.status == StatusChamado.aberto), isTrue);
    });

    test('estatísticas somam corretamente por status', () async {
      final todos = await service.listar();
      final stats = service.calcularEstatisticas(todos);
      expect(
        stats.abertos + stats.emAndamento + stats.concluidos,
        equals(stats.total),
      );
    });

    test('criar valida título curto', () async {
      expect(
        () => service.criar(
          titulo: 'oi',
          descricao: 'descrição suficientemente longa',
          categoria: Categoria.buraco,
          prioridade: Prioridade.baixa,
          bairro: 'Centro',
        ),
        throwsArgumentError,
      );
    });

    test('criar persiste um novo chamado como Aberto', () async {
      final novo = await service.criar(
        titulo: 'Novo problema na via',
        descricao: 'Descrição detalhada do problema urbano.',
        categoria: Categoria.lixo,
        prioridade: Prioridade.media,
        bairro: 'Vila Nova',
      );
      expect(novo.status, StatusChamado.aberto);
      expect(await service.obter(novo.id), isNotNull);
    });
  });

  testWidgets('App inicia e exibe o nome no Dashboard', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        // Garante repositório em memória (sem SQLite) no ambiente de teste.
        overrides: [
          chamadoRepositoryProvider.overrideWith(
            (ref) => InMemoryChamadoRepository(),
          ),
        ],
        child: const SosCidadeApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SOS Cidade'), findsWidgets);
  });
}
