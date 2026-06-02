import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Categorias de problemas urbanos suportadas pelo SOS Cidade.
enum Categoria {
  buraco('Buraco na Via', Icons.warning_amber_rounded),
  iluminacao('Iluminação Pública', Icons.lightbulb_outline),
  vazamento('Vazamento de Água', Icons.water_drop_outlined),
  lixo('Coleta de Lixo', Icons.delete_outline),
  sinalizacao('Sinalização', Icons.traffic_outlined),
  calcada('Calçada Danificada', Icons.directions_walk_outlined);

  const Categoria(this.label, this.icone);

  /// Texto exibido ao usuário.
  final String label;

  /// Ícone representativo da categoria.
  final IconData icone;
}

/// Nível de prioridade de um chamado.
enum Prioridade {
  baixa('Baixa', AppColors.neutral),
  media('Média', AppColors.primary),
  alta('Alta', AppColors.warning),
  critica('Crítica', AppColors.danger);

  const Prioridade(this.label, this.cor);

  final String label;

  /// Cor usada em badges e indicadores.
  final Color cor;
}

/// Estado atual de um chamado no fluxo de atendimento.
enum StatusChamado {
  aberto('Aberto', AppColors.primary, Icons.fiber_new_outlined),
  emAndamento('Em Andamento', AppColors.warning, Icons.autorenew_rounded),
  concluido('Concluído', AppColors.success, Icons.check_circle_outline);

  const StatusChamado(this.label, this.cor, this.icone);

  final String label;
  final Color cor;
  final IconData icone;
}

/// Representa um chamado (ocorrência urbana) registrado no sistema.
class Chamado {
  final String id;
  final String titulo;
  final String descricao;
  final Categoria categoria;
  final Prioridade prioridade;
  final StatusChamado status;
  final String bairro;
  final DateTime dataCriacao;

  const Chamado({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.status,
    required this.bairro,
    required this.dataCriacao,
  });

  /// Cria uma cópia do chamado alterando os campos informados.
  Chamado copyWith({
    String? id,
    String? titulo,
    String? descricao,
    Categoria? categoria,
    Prioridade? prioridade,
    StatusChamado? status,
    String? bairro,
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
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  /// Constrói um [Chamado] a partir de um mapa (ex.: futura integração com API).
  factory Chamado.fromMap(Map<String, dynamic> map) {
    return Chamado(
      id: map['id'] as String,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      categoria: Categoria.values.byName(map['categoria'] as String),
      prioridade: Prioridade.values.byName(map['prioridade'] as String),
      status: StatusChamado.values.byName(map['status'] as String),
      bairro: map['bairro'] as String,
      dataCriacao: DateTime.parse(map['dataCriacao'] as String),
    );
  }

  /// Serializa o chamado em um mapa.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria.name,
      'prioridade': prioridade.name,
      'status': status.name,
      'bairro': bairro,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }
}
