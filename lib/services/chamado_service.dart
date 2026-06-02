import '../models/chamado.dart';

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
}

/// Serviço responsável por fornecer e filtrar os chamados.
///
/// Nesta fase de MVP os dados são totalmente simulados (mockados),
/// sem qualquer integração com API. A interface, porém, já é assíncrona
/// para facilitar a futura troca por uma fonte de dados remota.
class ChamadoService {
  /// Retorna todos os chamados cadastrados.
  ///
  /// Simula uma pequena latência de rede para refletir um cenário real.
  Future<List<Chamado>> listarChamados() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<Chamado>.unmodifiable(_mock);
  }

  /// Versão síncrona dos dados mockados (útil para testes e estados iniciais).
  List<Chamado> listarChamadosSync() => List<Chamado>.unmodifiable(_mock);

  /// Calcula as estatísticas agregadas de uma lista de chamados.
  ChamadoEstatisticas calcularEstatisticas(List<Chamado> chamados) {
    return ChamadoEstatisticas(
      total: chamados.length,
      abertos: chamados
          .where((c) => c.status == StatusChamado.aberto)
          .length,
      emAndamento: chamados
          .where((c) => c.status == StatusChamado.emAndamento)
          .length,
      concluidos: chamados
          .where((c) => c.status == StatusChamado.concluido)
          .length,
      criticos: chamados
          .where((c) => c.prioridade == Prioridade.critica)
          .length,
    );
  }

  /// Aplica busca textual e filtros de categoria, status e prioridade.
  ///
  /// Parâmetros nulos significam "sem filtro" para aquele critério.
  List<Chamado> filtrar(
    List<Chamado> chamados, {
    String busca = '',
    Categoria? categoria,
    StatusChamado? status,
    Prioridade? prioridade,
  }) {
    final String termo = busca.trim().toLowerCase();

    final List<Chamado> resultado = chamados.where((c) {
      final bool casaBusca =
          termo.isEmpty || c.titulo.toLowerCase().contains(termo);
      final bool casaCategoria = categoria == null || c.categoria == categoria;
      final bool casaStatus = status == null || c.status == status;
      final bool casaPrioridade =
          prioridade == null || c.prioridade == prioridade;
      return casaBusca && casaCategoria && casaStatus && casaPrioridade;
    }).toList();

    // Ordena do mais recente para o mais antigo.
    resultado.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
    return resultado;
  }

  // --- Dados simulados -------------------------------------------------------

  static final DateTime _agora = DateTime.now();

  static final List<Chamado> _mock = [
    Chamado(
      id: '0001',
      titulo: 'Buraco enorme na Avenida Brasil',
      descricao:
          'Buraco profundo próximo ao número 1200, já causou danos em veículos. '
          'Necessita reparo urgente antes do período de chuvas.',
      categoria: Categoria.buraco,
      prioridade: Prioridade.critica,
      status: StatusChamado.aberto,
      bairro: 'Centro',
      dataCriacao: _agora.subtract(const Duration(hours: 3)),
    ),
    Chamado(
      id: '0002',
      titulo: 'Poste sem iluminação na Rua das Flores',
      descricao:
          'Três postes consecutivos estão apagados há mais de uma semana, '
          'deixando a rua perigosa à noite.',
      categoria: Categoria.iluminacao,
      prioridade: Prioridade.alta,
      status: StatusChamado.emAndamento,
      bairro: 'Jardim Primavera',
      dataCriacao: _agora.subtract(const Duration(days: 1, hours: 5)),
    ),
    Chamado(
      id: '0003',
      titulo: 'Vazamento de água na calçada',
      descricao:
          'Água jorrando continuamente da tubulação, desperdício enorme e '
          'risco de erosão na via.',
      categoria: Categoria.vazamento,
      prioridade: Prioridade.alta,
      status: StatusChamado.aberto,
      bairro: 'Vila Nova',
      dataCriacao: _agora.subtract(const Duration(hours: 9)),
    ),
    Chamado(
      id: '0004',
      titulo: 'Acúmulo de lixo na esquina',
      descricao:
          'Lixo não recolhido há vários dias, atraindo insetos e exalando '
          'mau cheiro próximo à escola municipal.',
      categoria: Categoria.lixo,
      prioridade: Prioridade.media,
      status: StatusChamado.emAndamento,
      bairro: 'Bela Vista',
      dataCriacao: _agora.subtract(const Duration(days: 2)),
    ),
    Chamado(
      id: '0005',
      titulo: 'Placa de pare derrubada',
      descricao:
          'Sinalização de parada obrigatória caiu após acidente e não foi '
          'reinstalada, aumentando o risco no cruzamento.',
      categoria: Categoria.sinalizacao,
      prioridade: Prioridade.critica,
      status: StatusChamado.aberto,
      bairro: 'Industrial',
      dataCriacao: _agora.subtract(const Duration(hours: 18)),
    ),
    Chamado(
      id: '0006',
      titulo: 'Calçada quebrada em frente ao mercado',
      descricao:
          'Piso totalmente irregular dificulta a passagem de pedestres e '
          'cadeirantes.',
      categoria: Categoria.calcada,
      prioridade: Prioridade.media,
      status: StatusChamado.concluido,
      bairro: 'Centro',
      dataCriacao: _agora.subtract(const Duration(days: 5)),
    ),
    Chamado(
      id: '0007',
      titulo: 'Buraco na Rua dos Ipês',
      descricao:
          'Pequeno buraco em formação que tende a aumentar com o tráfego de '
          'caminhões.',
      categoria: Categoria.buraco,
      prioridade: Prioridade.baixa,
      status: StatusChamado.aberto,
      bairro: 'Jardim Primavera',
      dataCriacao: _agora.subtract(const Duration(days: 1, hours: 2)),
    ),
    Chamado(
      id: '0008',
      titulo: 'Lâmpada queimada na praça central',
      descricao:
          'Iluminação da praça parcialmente comprometida, prejudicando o uso '
          'noturno do espaço público.',
      categoria: Categoria.iluminacao,
      prioridade: Prioridade.media,
      status: StatusChamado.concluido,
      bairro: 'Centro',
      dataCriacao: _agora.subtract(const Duration(days: 7)),
    ),
    Chamado(
      id: '0009',
      titulo: 'Cano estourado alaga a via',
      descricao:
          'Rompimento de adutora causa alagamento e falta de água nas '
          'residências vizinhas.',
      categoria: Categoria.vazamento,
      prioridade: Prioridade.critica,
      status: StatusChamado.emAndamento,
      bairro: 'Vila Nova',
      dataCriacao: _agora.subtract(const Duration(hours: 6)),
    ),
    Chamado(
      id: '0010',
      titulo: 'Lixeira pública danificada',
      descricao:
          'Lixeira da praça quebrada, lixo se espalha pelo chão com o vento.',
      categoria: Categoria.lixo,
      prioridade: Prioridade.baixa,
      status: StatusChamado.aberto,
      bairro: 'Bela Vista',
      dataCriacao: _agora.subtract(const Duration(days: 3, hours: 4)),
    ),
    Chamado(
      id: '0011',
      titulo: 'Semáforo intermitente no cruzamento',
      descricao:
          'Semáforo piscando em amarelo o dia inteiro, gerando confusão entre '
          'os motoristas.',
      categoria: Categoria.sinalizacao,
      prioridade: Prioridade.alta,
      status: StatusChamado.emAndamento,
      bairro: 'Industrial',
      dataCriacao: _agora.subtract(const Duration(days: 1, hours: 10)),
    ),
    Chamado(
      id: '0012',
      titulo: 'Raiz de árvore levanta a calçada',
      descricao:
          'Calçada erguida por raízes apresenta degraus perigosos para os '
          'pedestres.',
      categoria: Categoria.calcada,
      prioridade: Prioridade.alta,
      status: StatusChamado.aberto,
      bairro: 'Parque das Águas',
      dataCriacao: _agora.subtract(const Duration(days: 2, hours: 8)),
    ),
    Chamado(
      id: '0013',
      titulo: 'Buraco recorrente após chuva',
      descricao:
          'Trecho da via volta a abrir buracos sempre que chove, asfalto mal '
          'recomposto.',
      categoria: Categoria.buraco,
      prioridade: Prioridade.media,
      status: StatusChamado.concluido,
      bairro: 'Parque das Águas',
      dataCriacao: _agora.subtract(const Duration(days: 9)),
    ),
    Chamado(
      id: '0014',
      titulo: 'Falta de iluminação em viela',
      descricao:
          'Viela sem nenhum ponto de luz, moradores relatam sensação de '
          'insegurança.',
      categoria: Categoria.iluminacao,
      prioridade: Prioridade.alta,
      status: StatusChamado.aberto,
      bairro: 'Vila Nova',
      dataCriacao: _agora.subtract(const Duration(hours: 22)),
    ),
    Chamado(
      id: '0015',
      titulo: 'Coleta seletiva não passou',
      descricao:
          'Caminhão da coleta seletiva não passou na data prevista, recicláveis '
          'acumulados nas calçadas.',
      categoria: Categoria.lixo,
      prioridade: Prioridade.baixa,
      status: StatusChamado.concluido,
      bairro: 'Jardim Primavera',
      dataCriacao: _agora.subtract(const Duration(days: 4)),
    ),
    Chamado(
      id: '0016',
      titulo: 'Pichação em placa de rua',
      descricao:
          'Placa de identificação da rua coberta por pichação, ilegível para '
          'quem chega ao bairro.',
      categoria: Categoria.sinalizacao,
      prioridade: Prioridade.baixa,
      status: StatusChamado.emAndamento,
      bairro: 'Bela Vista',
      dataCriacao: _agora.subtract(const Duration(days: 6, hours: 3)),
    ),
    Chamado(
      id: '0017',
      titulo: 'Vazamento lento em hidrante',
      descricao:
          'Hidrante com pequeno vazamento constante, água escorre pela '
          'sarjeta o dia todo.',
      categoria: Categoria.vazamento,
      prioridade: Prioridade.media,
      status: StatusChamado.aberto,
      bairro: 'Centro',
      dataCriacao: _agora.subtract(const Duration(days: 1, hours: 16)),
    ),
  ];
}
