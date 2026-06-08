import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chamado.dart';
import '../services/chamado_service.dart';

/// Estado imutável da tela de chamados (lista + filtros + status de carga).
class ChamadoState {
  /// Todos os chamados carregados da fonte de dados.
  final List<Chamado> todos;

  /// Resultado já filtrado/buscado, pronto para a View renderizar.
  final List<Chamado> filtrados;

  /// Estatísticas agregadas para o Dashboard.
  final ChamadoEstatisticas estatisticas;

  /// Filtros atualmente aplicados.
  final FiltroChamado filtro;

  final bool carregando;
  final String? erro;

  const ChamadoState({
    this.todos = const [],
    this.filtrados = const [],
    this.estatisticas = ChamadoEstatisticas.vazio,
    this.filtro = const FiltroChamado(),
    this.carregando = false,
    this.erro,
  });

  ChamadoState copyWith({
    List<Chamado>? todos,
    List<Chamado>? filtrados,
    ChamadoEstatisticas? estatisticas,
    FiltroChamado? filtro,
    bool? carregando,
    String? erro,
    bool limparErro = false,
  }) {
    return ChamadoState(
      todos: todos ?? this.todos,
      filtrados: filtrados ?? this.filtrados,
      estatisticas: estatisticas ?? this.estatisticas,
      filtro: filtro ?? this.filtro,
      carregando: carregando ?? this.carregando,
      erro: limparErro ? null : (erro ?? this.erro),
    );
  }
}

/// Controller responsável por mediar a View e o [ChamadoService].
///
/// Mantém o estado da tela e expõe ações (carregar, filtrar, criar...). A View
/// nunca fala diretamente com Service/Repository — apenas observa este estado
/// e chama estes métodos. Isso mantém a UI "burra" e centraliza a lógica de
/// orquestração, evitando conflitos entre quem desenvolve telas diferentes.
class ChamadoController extends StateNotifier<ChamadoState> {
  ChamadoController(this._service) : super(const ChamadoState());

  final ChamadoService _service;

  /// Carrega (ou recarrega) os chamados da fonte de dados.
  Future<void> carregar() async {
    state = state.copyWith(carregando: true, limparErro: true);
    try {
      final todos = await _service.listar();
      state = state.copyWith(
        todos: todos,
        filtrados: _service.filtrar(todos, state.filtro),
        estatisticas: _service.calcularEstatisticas(todos),
        carregando: false,
      );
    } catch (e) {
      state = state.copyWith(carregando: false, erro: e.toString());
    }
  }

  /// Cria um novo chamado e recarrega a lista.
  Future<void> criar({
    required String titulo,
    required String descricao,
    required Categoria categoria,
    required Prioridade prioridade,
    required String bairro,
    String? responsavel,
  }) async {
    await _service.criar(
      titulo: titulo,
      descricao: descricao,
      categoria: categoria,
      prioridade: prioridade,
      bairro: bairro,
      responsavel: responsavel,
    );
    await carregar();
  }

  // --- Filtros e busca (recalculam a lista filtrada localmente) -------------

  void buscar(String termo) => _aplicarFiltro(state.filtro.copyWith(busca: termo));

  void filtrarPorCategoria(Categoria? categoria) => _aplicarFiltro(
        state.filtro.copyWith(
          categoria: categoria,
          limparCategoria: categoria == null,
        ),
      );

  void filtrarPorStatus(StatusChamado? status) => _aplicarFiltro(
        state.filtro.copyWith(status: status, limparStatus: status == null),
      );

  void filtrarPorPrioridade(Prioridade? prioridade) => _aplicarFiltro(
        state.filtro.copyWith(
          prioridade: prioridade,
          limparPrioridade: prioridade == null,
        ),
      );

  void limparFiltros() => _aplicarFiltro(const FiltroChamado());

  void _aplicarFiltro(FiltroChamado filtro) {
    state = state.copyWith(
      filtro: filtro,
      filtrados: _service.filtrar(state.todos, filtro),
    );
  }
}
