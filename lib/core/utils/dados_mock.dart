import '../../models/chamado.dart';

/// Massa de dados de exemplo usada para popular o banco na primeira execução
/// e para abastecer o repositório em memória durante o desenvolvimento/testes.
///
/// Centralizar a semente em um único lugar evita divergência entre as fontes
/// de dados (SQLite x memória) e facilita a vida de quem desenvolve a UI antes
/// de a persistência estar 100% pronta.
class DadosMock {
  DadosMock._();

  static final DateTime _agora = DateTime.now();

  static List<Chamado> gerar() => [
        Chamado(
          id: '0001',
          titulo: 'Buraco enorme na Avenida Brasil',
          descricao:
              'Buraco profundo próximo ao nº 1200, já causou danos em veículos.',
          categoria: Categoria.buraco,
          prioridade: Prioridade.critica,
          status: StatusChamado.aberto,
          bairro: 'Centro',
          dataCriacao: _agora.subtract(const Duration(hours: 3)),
        ),
        Chamado(
          id: '0002',
          titulo: 'Rua sem iluminação no Jardim Primavera',
          descricao:
              'Três postes apagados há mais de uma semana, rua perigosa à noite.',
          categoria: Categoria.iluminacao,
          prioridade: Prioridade.alta,
          status: StatusChamado.emAndamento,
          bairro: 'Jardim Primavera',
          responsavel: 'Equipe de Iluminação',
          dataCriacao: _agora.subtract(const Duration(days: 1, hours: 5)),
        ),
        Chamado(
          id: '0003',
          titulo: 'Vazamento de água na calçada',
          descricao: 'Água jorrando da tubulação, risco de erosão na via.',
          categoria: Categoria.vazamento,
          prioridade: Prioridade.alta,
          status: StatusChamado.aberto,
          bairro: 'Vila Nova',
          dataCriacao: _agora.subtract(const Duration(hours: 9)),
        ),
        Chamado(
          id: '0004',
          titulo: 'Semáforo apagado em cruzamento movimentado',
          descricao: 'Semáforo totalmente apagado, risco alto de acidentes.',
          categoria: Categoria.semaforo,
          prioridade: Prioridade.critica,
          status: StatusChamado.emAndamento,
          bairro: 'Industrial',
          responsavel: 'CET Municipal',
          dataCriacao: _agora.subtract(const Duration(hours: 18)),
        ),
        Chamado(
          id: '0005',
          titulo: 'Acúmulo de lixo próximo à escola',
          descricao: 'Lixo não recolhido há dias, atraindo insetos.',
          categoria: Categoria.lixo,
          prioridade: Prioridade.media,
          status: StatusChamado.emAndamento,
          bairro: 'Bela Vista',
          dataCriacao: _agora.subtract(const Duration(days: 2)),
        ),
        Chamado(
          id: '0006',
          titulo: 'Árvore caída bloqueando a via',
          descricao: 'Árvore de grande porte caiu após temporal e bloqueia a rua.',
          categoria: Categoria.arvore,
          prioridade: Prioridade.critica,
          status: StatusChamado.aberto,
          bairro: 'Parque das Águas',
          dataCriacao: _agora.subtract(const Duration(hours: 6)),
        ),
        Chamado(
          id: '0007',
          titulo: 'Alagamento recorrente na Rua das Flores',
          descricao: 'Rua alaga a cada chuva forte, bueiros entupidos.',
          categoria: Categoria.enchente,
          prioridade: Prioridade.alta,
          status: StatusChamado.aberto,
          bairro: 'Centro',
          dataCriacao: _agora.subtract(const Duration(days: 1, hours: 2)),
        ),
        Chamado(
          id: '0008',
          titulo: 'Lâmpada queimada na praça central',
          descricao: 'Iluminação parcial da praça, prejudica uso noturno.',
          categoria: Categoria.iluminacao,
          prioridade: Prioridade.baixa,
          status: StatusChamado.concluido,
          bairro: 'Centro',
          responsavel: 'Equipe de Iluminação',
          dataCriacao: _agora.subtract(const Duration(days: 7)),
        ),
        Chamado(
          id: '0009',
          titulo: 'Buraco recorrente após chuva',
          descricao: 'Asfalto mal recomposto reabre buracos sempre que chove.',
          categoria: Categoria.buraco,
          prioridade: Prioridade.media,
          status: StatusChamado.concluido,
          bairro: 'Parque das Águas',
          responsavel: 'Secretaria de Obras',
          dataCriacao: _agora.subtract(const Duration(days: 9)),
        ),
        Chamado(
          id: '0010',
          titulo: 'Coleta de lixo não passou',
          descricao: 'Caminhão da coleta não passou na data prevista.',
          categoria: Categoria.lixo,
          prioridade: Prioridade.baixa,
          status: StatusChamado.concluido,
          bairro: 'Jardim Primavera',
          dataCriacao: _agora.subtract(const Duration(days: 4)),
        ),
      ];
}
