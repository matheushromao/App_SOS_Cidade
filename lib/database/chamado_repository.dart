import '../models/chamado.dart';
import 'database_helper.dart';

class ChamadoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  /// Salva um novo chamado no banco de dados
  /// Lança Exception se o título já existe
  Future<void> salvar(Chamado chamado) async {
    try {
      await _databaseHelper.salvarChamado(chamado);
    } catch (e) {
      rethrow;
    }
  }

  /// Lista todos os chamados do banco com ordenação de prioridade
  /// Crítica e Alta no topo, depois por data mais recente
  Future<List<Chamado>> listarTodos() async {
    try {
      return await _databaseHelper.listarChamados();
    } catch (e) {
      rethrow;
    }
  }

  /// Atualiza o status de um chamado
  /// Lança Exception se o chamado já está concluído
  Future<void> atualizarStatus(String id, StatusChamado novoStatus) async {
    try {
      await _databaseHelper.atualizarStatus(id, novoStatus);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtém as estatísticas agregadas do dashboard
  Future<Map<String, int>> obterEstatisticas() async {
    try {
      return await _databaseHelper.obterEstatisticasDashboard();
    } catch (e) {
      rethrow;
    }
  }
}
