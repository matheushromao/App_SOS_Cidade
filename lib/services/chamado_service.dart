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
/// filtragem, ordenação por prioridade e cálculo de estatísticas. É uma camada
/// pura e testável (recebe o repositório por injeção de dependência).
class ChamadoService {
  ChamadoService(this._repository);

  final ChamadoRepository _repository;

  // --- Operações de dados (delegadas ao repositório) ------------------------

  /// Lista todos os chamados já ordenados (críticos/altos primeiro).
  Future<List<Chamado>> listar() async {
    final lista = await _repository.buscarTodos();
    _ordenar(lista);
    return lista;
  }

  Future<Chamado?> obter(String id) => _repository.buscarPorId(id);

  /// Cria um novo chamado aplicando validação e valores padrão.
  ///
  /// Por padrão o chamado nasce com status [StatusChamado.aberto] e data atual,
  /// mas ambos podem ser informados pelo formulário de cadastro.
  /// Lança [ArgumentError] em dados inválidos e [StateError] se o título já
  /// existir (regra: não permitir título repetido).
  Future<Chamado> criar({
    required String titulo,
    required String descricao,
    required Categoria categoria,
    required Prioridade prioridade,
    required String bairro,
    String? responsavel,
    StatusChamado status = StatusChamado.aberto,
    DateTime? dataCriacao,
  }) async {
    _validar(titulo: titulo, descricao: descricao, bairro: bairro);
    await _garantirTituloUnico(titulo);

    final chamado = Chamado(
      id: _gerarId(),
      titulo: titulo.trim(),
      descricao: descricao.trim(),
      categoria: categoria,
      prioridade: prioridade,
      status: status,
      bairro: bairro.trim(),
      responsavel: (responsavel == null || responsavel.trim().isEmpty)
          ? null
          : responsavel.trim(),
      dataCriacao: dataCriacao ?? DateTime.now(),
    );

    await _repository.inserir(chamado);
    return chamado;
  }

  /// Atualiza um chamado existente.
  ///
  /// Regra de negócio: chamados já concluídos não podem ser editados.
  Future<void> atualizar(Chamado chamado) async {
    final atual = await _repository.buscarPorId(chamado.id);
    if (atual != null && atual.status == StatusChamado.concluido) {
      throw StateError('Chamados concluídos não podem ser editados.');
    }
    _validar(
      titulo: chamado.titulo,
      descricao: chamado.descricao,
      bairro: chamado.bairro,
    );
    await _garantirTituloUnico(chamado.titulo, ignorarId: chamado.id);
    await _repository.atualizar(chamado);
  }

  Future<void> remover(String id) => _repository.remover(id);

  // --- Regras de negócio puras (sem I/O) ------------------------------------

  /// Aplica busca textual (por título) e filtros de categoria/status/prioridade.
  /// O resultado já vem ordenado com críticos/altos no topo.
  List<Chamado> filtrar(List<Chamado> chamados, FiltroChamado filtro) {
    final termo = filtro.busca.trim().toLowerCase();

    final resultado = chamados.where((c) {
      final casaBusca = termo.isEmpty ||
          c.titulo.toLowerCase().contains(termo) ||
          c.descricao.toLowerCase().contains(termo) ||
          c.bairro.toLowerCase().contains(termo);
      final casaCategoria =
          filtro.categoria == null || c.categoria == filtro.categoria;
      final casaStatus = filtro.status == null || c.status == filtro.status;
      final casaPrioridade =
          filtro.prioridade == null || c.prioridade == filtro.prioridade;
      return casaBusca && casaCategoria && casaStatus && casaPrioridade;
    }).toList();

    _ordenar(resultado);
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

  /// Ordena in-place: prioridade (crítica > alta > média > baixa) e, dentro de
  /// cada nível, do mais recente para o mais antigo.
  void _ordenar(List<Chamado> chamados) {
    chamados.sort((a, b) {
      final porPrioridade = _peso(a.prioridade).compareTo(_peso(b.prioridade));
      if (porPrioridade != 0) return porPrioridade;
      return b.dataCriacao.compareTo(a.dataCriacao);
    });
  }

  int _peso(Prioridade p) {
    switch (p) {
      case Prioridade.critica:
        return 0;
      case Prioridade.alta:
        return 1;
      case Prioridade.media:
        return 2;
      case Prioridade.baixa:
        return 3;
    }
  }

  void _validar({
    required String titulo,
    required String descricao,
    required String bairro,
  }) {
    if (titulo.trim().length < 5) {
      throw ArgumentError('O título deve ter ao menos 5 caracteres.');
    }
    if (descricao.trim().isEmpty) {
      throw ArgumentError('A descrição não pode ficar vazia.');
    }
    if (bairro.trim().isEmpty) {
      throw ArgumentError('Informe o bairro.');
    }
  }

  /// Garante que não exista outro chamado com o mesmo título (case-insensitive).
  Future<void> _garantirTituloUnico(String titulo, {String? ignorarId}) async {
    final alvo = titulo.trim().toLowerCase();
    final existentes = await _repository.buscarTodos();
    final repetido = existentes.any(
      (c) => c.id != ignorarId && c.titulo.trim().toLowerCase() == alvo,
    );
    if (repetido) {
      throw StateError('Já existe um chamado com este título.');
    }
  }

  /// Gera um identificador simples e único o suficiente para o MVP.
  String _gerarId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}
