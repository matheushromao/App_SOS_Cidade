import 'dart:convert';

/// Categorias de problemas urbanos suportadas pelo SOS Cidade.
///
/// O [name] de cada valor (ex.: `buraco`) é o que será persistido no banco.
/// O rótulo de exibição fica em [label]. As cores e ícones NÃO ficam aqui:
/// o model é mantido livre de dependências do Flutter para poder ser testado
/// isoladamente e reutilizado em qualquer camada. O mapeamento visual está em
/// `views/shared/chamado_presentation.dart`.
enum Categoria {
  buraco('Buraco na Via'),
  iluminacao('Falta de Iluminação'),
  vazamento('Vazamento de Água'),
  acidente('Acidente'),
  semaforo('Semáforo Quebrado'),
  lixo('Lixo Acumulado'),
  arvore('Árvore Caída'),
  enchente('Enchente');

  const Categoria(this.label);

  /// Texto exibido ao usuário.
  final String label;

  /// Converte um valor persistido de volta para o enum, com segurança.
  static Categoria fromName(String value) =>
      Categoria.values.firstWhere(
        (c) => c.name == value,
        orElse: () => Categoria.buraco,
      );
}

/// Nível de prioridade de um chamado.
enum Prioridade {
  baixa('Baixa'),
  media('Média'),
  alta('Alta'),
  critica('Crítica');

  const Prioridade(this.label);

  final String label;

  static Prioridade fromName(String value) =>
      Prioridade.values.firstWhere(
        (p) => p.name == value,
        orElse: () => Prioridade.media,
      );
}

/// Estado atual de um chamado no fluxo de atendimento.
enum StatusChamado {
  aberto('Aberto'),
  emAndamento('Em Andamento'),
  concluido('Concluído');

  const StatusChamado(this.label);

  final String label;

  static StatusChamado fromName(String value) =>
      StatusChamado.values.firstWhere(
        (s) => s.name == value,
        orElse: () => StatusChamado.aberto,
      );
}

/// Representa um chamado (ocorrência urbana) registrado no sistema.
///
/// Classe de domínio imutável. Toda a (de)serialização necessária para o
/// SQLite ([toMap]/[fromMap]) e para APIs/JSON ([toJson]/[fromJson]) está
/// centralizada aqui, garantindo uma única fonte de verdade do formato.
class Chamado {
  final String id;
  final String titulo;
  final String descricao;
  final Categoria categoria;
  final Prioridade prioridade;
  final StatusChamado status;
  final String bairro;

  /// Servidor/equipe responsável pelo atendimento. Nulo enquanto não atribuído.
  final String? responsavel;

  final DateTime dataCriacao;

  const Chamado({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.status,
    required this.bairro,
    this.responsavel,
    required this.dataCriacao,
  });

  /// Cria uma cópia do chamado alterando apenas os campos informados.
  ///
  /// Use [limparResponsavel] para definir explicitamente `responsavel = null`
  /// (já que passar `null` no parâmetro significa "manter o valor atual").
  Chamado copyWith({
    String? id,
    String? titulo,
    String? descricao,
    Categoria? categoria,
    Prioridade? prioridade,
    StatusChamado? status,
    String? bairro,
    String? responsavel,
    bool limparResponsavel = false,
    DateTime? dataCriacao,
  }) {
    return Chamado(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      prioridade: prioridade ?? this.prioridade,
      status: status ?? this.status,
      bairro: bairro ?? this.bairro,
      responsavel:
          limparResponsavel ? null : (responsavel ?? this.responsavel),
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  // --- Serialização para Map (SQLite) ---------------------------------------

  /// Constrói um [Chamado] a partir de um mapa (linha do banco / JSON decodado).
  factory Chamado.fromMap(Map<String, dynamic> map) {
    return Chamado(
      id: map['id'] as String,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      categoria: Categoria.fromName(map['categoria'] as String),
      prioridade: Prioridade.fromName(map['prioridade'] as String),
      status: StatusChamado.fromName(map['status'] as String),
      bairro: map['bairro'] as String,
      responsavel: map['responsavel'] as String?,
      dataCriacao: DateTime.parse(map['dataCriacao'] as String),
    );
  }

  /// Serializa o chamado em um mapa compatível com as colunas do SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria.name,
      'prioridade': prioridade.name,
      'status': status.name,
      'bairro': bairro,
      'responsavel': responsavel,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  // --- Serialização para JSON (APIs / arquivos) -----------------------------

  /// Constrói um [Chamado] a partir de uma String JSON.
  factory Chamado.fromJson(String source) =>
      Chamado.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Serializa o chamado em uma String JSON.
  String toJson() => json.encode(toMap());

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Chamado && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Chamado(id: $id, titulo: $titulo, status: ${status.name})';
}
