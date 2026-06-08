import 'dart:math';

import '../../models/chamado.dart';

/// Massa de dados fictícios usada para popular o banco na primeira execução
/// e para abastecer o repositório em memória durante o desenvolvimento/testes.
///
/// Os chamados são gerados **aleatoriamente** (categoria, prioridade, status,
/// bairro, responsável e data), porém com uma semente fixa por padrão para que
/// a massa seja reproduzível entre execuções. Os títulos são únicos para
/// respeitar a regra de negócio "não permitir título repetido".
class DadosMock {
  DadosMock._();

  static const List<String> _bairros = [
    'Centro',
    'Jardim Primavera',
    'Vila Nova',
    'Industrial',
    'Bela Vista',
    'Parque das Águas',
    'São José',
    'Santa Luzia',
    'Boa Vista',
    'Alto da Serra',
  ];

  static const List<String> _responsaveis = [
    'Secretaria de Obras',
    'Equipe de Iluminação',
    'CET Municipal',
    'Defesa Civil',
    'Companhia de Saneamento',
    'Zeladoria Urbana',
  ];

  /// Frases de descrição por categoria, para gerar textos plausíveis.
  static const Map<Categoria, List<String>> _descricoes = {
    Categoria.buraco: [
      'Buraco profundo na pista, já causou danos em veículos.',
      'Asfalto cedeu após as últimas chuvas, risco para motociclistas.',
    ],
    Categoria.iluminacao: [
      'Postes apagados há vários dias, rua perigosa à noite.',
      'Lâmpada queimada deixando o trecho totalmente escuro.',
    ],
    Categoria.vazamento: [
      'Água jorrando da tubulação, risco de erosão na via.',
      'Vazamento constante alagando a calçada e desperdiçando água.',
    ],
    Categoria.acidente: [
      'Ponto com histórico de colisões, sinalização insuficiente.',
      'Veículo colidiu em obstáculo na via sem sinalização.',
    ],
    Categoria.semaforo: [
      'Semáforo apagado em cruzamento movimentado.',
      'Semáforo piscando em amarelo há dias, gerando confusão.',
    ],
    Categoria.lixo: [
      'Lixo acumulado não recolhido, atraindo insetos e roedores.',
      'Descarte irregular de entulho na esquina.',
    ],
    Categoria.arvore: [
      'Árvore de grande porte caiu após temporal e bloqueia a rua.',
      'Galhos comprometidos ameaçam cair sobre a fiação.',
    ],
    Categoria.enchente: [
      'Rua alaga a cada chuva forte, bueiros entupidos.',
      'Acúmulo de água impede a passagem de pedestres.',
    ],
  };

  /// Gera uma lista de [quantidade] chamados aleatórios.
  ///
  /// [seed] fixa a aleatoriedade (reprodutível). Passe `null` para variar a
  /// cada chamada.
  static List<Chamado> gerar({int quantidade = 14, int? seed = 42}) {
    final rnd = Random(seed);
    final categorias = Categoria.values;
    final prioridades = Prioridade.values;
    final status = StatusChamado.values;

    return List.generate(quantidade, (i) {
      final categoria = categorias[rnd.nextInt(categorias.length)];
      final prioridade = prioridades[rnd.nextInt(prioridades.length)];
      final st = status[rnd.nextInt(status.length)];
      final bairro = _bairros[rnd.nextInt(_bairros.length)];
      final descricoes = _descricoes[categoria]!;
      final descricao = descricoes[rnd.nextInt(descricoes.length)];

      // Data nas últimas ~30 dias (com hora/minuto aleatórios).
      final dataCriacao = DateTime.now().subtract(
        Duration(
          days: rnd.nextInt(30),
          hours: rnd.nextInt(24),
          minutes: rnd.nextInt(60),
        ),
      );

      // Responsável apenas para chamados que já saíram de "Aberto".
      final responsavel = st == StatusChamado.aberto
          ? null
          : _responsaveis[rnd.nextInt(_responsaveis.length)];

      // Título único: rótulo da categoria + bairro + nº de protocolo.
      final numero = (i + 1).toString().padLeft(4, '0');
      final titulo = '${categoria.label} no $bairro (#$numero)';

      return Chamado(
        id: numero,
        titulo: titulo,
        descricao: descricao,
        categoria: categoria,
        prioridade: prioridade,
        status: st,
        bairro: bairro,
        responsavel: responsavel,
        dataCriacao: dataCriacao,
      );
    });
  }
}
