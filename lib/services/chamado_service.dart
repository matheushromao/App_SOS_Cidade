import '../models/chamado.dart';
import '../database/chamado_repository.dart'; // Verifique se o caminho bate com a sua estrutura de pastas

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

/// Serviço responsável por conectar a UI ao Banco de Dados SQLite.
class ChamadoService {
  // Injetando o seu repositório aqui
  final ChamadoRepository _repository = ChamadoRepository();

  /// 1. Retorna todos os chamados reais do Banco de Dados (com ordenação de prioridade)
  Future<List<Chamado>> listarChamados() async {
    return await _repository.listarTodos();
  }

  /// 2. NOVO: Método para a Pessoa 6 (Cadastro) salvar no SQLite
  Future<void> cadastrarChamado(Chamado chamado) async {
    await _repository.salvar(chamado);
  }

  /// 3. NOVO: Método para atualizar o status (com trava de concluído)
  Future<void> alterarStatus(String id, StatusChamado novoStatus) async {
    await _repository.atualizarStatus(id, novoStatus);
  }

  /// Calcula as estatísticas agregadas (Mantido em memória para não quebrar a UI da Pessoa 4)
  ChamadoEstatisticas calcularEstatisticas(List<Chamado> chamados) {
    return ChamadoEstatisticas(
      total: chamados.length,
      abertos: chamados.where((c) => c.status == StatusChamado.aberto).length,
      emAndamento: chamados.where((c) => c.status == StatusChamado.emAndamento).length,
      concluidos: chamados.where((c) => c.status == StatusChamado.concluido).length,
      criticos: chamados.where((c) => c.prioridade == Prioridade.critica).length,
    );
  }

  /// Aplica busca textual e filtros (Mantido em memória para não quebrar a UI da Pessoa 8)
  List<Chamado> filtrar(
    List<Chamado> chamados, {
    String busca = '',
    Categoria? categoria,
    StatusChamado? status,
    Prioridade? prioridade,
  }) {
    final String termo = busca.trim().toLowerCase();

    final List<Chamado> resultado = chamados.where((c) {
      final bool casaBusca = termo.isEmpty || c.titulo.toLowerCase().contains(termo) || c.descricao.toLowerCase().contains(termo) || c.bairro.toLowerCase().contains(termo);
      final bool casaCategoria = categoria == null || c.categoria == categoria;
      final bool casaStatus = status == null || c.status == status;
      final bool casaPrioridade = prioridade == null || c.prioridade == prioridade;
      return casaBusca && casaCategoria && casaStatus && casaPrioridade;
    }).toList();

    // Ordena do mais recente para o mais antigo.
    resultado.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
    return resultado;
  }
}
