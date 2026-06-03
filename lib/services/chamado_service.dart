import '../models/chamado.dart';
import '../repositories/chamado_repository.dart';

/// Agrupa as contagens estatísticas exibidas no Dashboard.
class ChamadoEstatisticas {
  final int total;
  final int abertos;
  final int emAndamento;
  final int concluidos;
  final int criticos;

  const ChamadoEstatisticas({
    required this.total,
    required this.abertos,
    required this.emAndamento,
    required this.concluidos,
    required this.criticos,
  });

  static const ChamadoEstatisticas vazio = ChamadoEstatisticas(
    total: 0,
    abertos: 0,
    emAndamento: 0,
    concluidos: 0,
    criticos: 0,
  );
}

/// Critérios de filtragem aplicados a uma lista de chamados.
class FiltroChamado {
  final String busca;
  final Categoria? categoria;
  final StatusChamado? status;
  final Prioridade? prioridade;

  const FiltroChamado({
    this.busca = '',
    this.categoria,
    this.status,
    this.prioridade,
  });

  bool get vazio =>
      busca.isEmpty &&
      categoria == null &&
      status == null &&
      prioridade == null;

  FiltroChamado copyWith({
    String? busca,
    Categoria? categoria,
    StatusChamado? status,
    Prioridade? prioridade,
    bool limparCategoria = false,
    bool limparStatus = false,
    bool limparPrioridade = false,
  }) {
    return FiltroChamado(
      busca: busca ?? this.busca,
      categoria: limparCategoria ? null : (categoria ?? this.categoria),
      status: limparStatus ? null : (status ?? this.status),
      prioridade: limparPrioridade ? null : (prioridade ?? this.prioridade),
    );
  }
}

/// Camada de regras de negócio sobre chamados.
///
/// Orquestra o [ChamadoRepository] (persistência) e concentra a lógica que
/// não pertence nem à UI nem ao banco: validações, geração de identificadores,
/// filtragem e cálculo de estatísticas. É uma camada pura e testável.
class ChamadoService {
  ChamadoService(this._repository);

  final ChamadoRepository _repository;

  // --- Operações de dados (delegadas ao repositório) ------------------------

  Future<List<Chamado>> listar() => _repository.buscarTodos();

  Future<Chamado?> obter(String id) => _repository.buscarPorId(id);

  /// Cria um novo chamado aplicando validação e valores padrão.
  Future<Chamado> criar({
    required String titulo,
    required String descricao,
    required Categoria categoria,
    required Prioridade prioridade,
    required String bairro,
    String? responsavel,
  }) async {
    _validar(titulo: titulo, descricao: descricao, bairro: bairro);

    final chamado = Chamado(
      id: _gerarId(),
      titulo: titulo.trim(),
      descricao: descricao.trim(),
      categoria: categoria,
      prioridade: prioridade,
      status: StatusChamado.aberto, // todo chamado novo nasce "Aberto".
      bairro: bairro.trim(),
      responsavel: responsavel?.trim(),
      dataCriacao: DateTime.now(),
    );

    await _repository.inserir(chamado);
    return chamado;
  }

  Future<void> atualizar(Chamado chamado) async {
    _validar(
      titulo: chamado.titulo,
      descricao: chamado.descricao,
      bairro: chamado.bairro,
    );
    await _repository.atualizar(chamado);
  }

  Future<void> remover(String id) => _repository.remover(id);

  // --- Regras de negócio puras (sem I/O) ------------------------------------

  /// Aplica busca textual (por título) e filtros de categoria/status/prioridade.
  List<Chamado> filtrar(List<Chamado> chamados, FiltroChamado filtro) {
    final termo = filtro.busca.trim().toLowerCase();

    final resultado = chamados.where((c) {
      final casaBusca =
          termo.isEmpty || c.titulo.toLowerCase().contains(termo);
      final casaCategoria =
          filtro.categoria == null || c.categoria == filtro.categoria;
      final casaStatus = filtro.status == null || c.status == filtro.status;
      final casaPrioridade =
          filtro.prioridade == null || c.prioridade == filtro.prioridade;
      return casaBusca && casaCategoria && casaStatus && casaPrioridade;
    }).toList();

    resultado.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
    return resultado;
  }

  /// Calcula as estatísticas agregadas de uma lista de chamados.
  ChamadoEstatisticas calcularEstatisticas(List<Chamado> chamados) {
    return ChamadoEstatisticas(
      total: chamados.length,
      abertos:
          chamados.where((c) => c.status == StatusChamado.aberto).length,
      emAndamento: chamados
          .where((c) => c.status == StatusChamado.emAndamento)
          .length,
      concluidos:
          chamados.where((c) => c.status == StatusChamado.concluido).length,
      criticos:
          chamados.where((c) => c.prioridade == Prioridade.critica).length,
    );
  }

  // --- Internos -------------------------------------------------------------

  void _validar({
    required String titulo,
    required String descricao,
    required String bairro,
  }) {
    if (titulo.trim().length < 5) {
      throw ArgumentError('O título deve ter ao menos 5 caracteres.');
    }
    if (descricao.trim().length < 10) {
      throw ArgumentError('A descrição deve ter ao menos 10 caracteres.');
    }
    if (bairro.trim().isEmpty) {
      throw ArgumentError('Informe o bairro.');
    }
  }

  /// Gera um identificador simples e único o suficiente para o MVP.
  String _gerarId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}
