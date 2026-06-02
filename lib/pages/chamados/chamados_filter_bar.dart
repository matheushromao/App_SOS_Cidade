import 'package:flutter/material.dart';

import '../../models/chamado.dart';
import '../../widgets/common/filter_dropdown.dart';

/// Barra horizontal com os filtros de categoria, status e prioridade.
///
/// Mantida desacoplada do Dashboard para poder ser reutilizada em
/// futuras telas dedicadas à listagem de chamados.
class ChamadosFilterBar extends StatelessWidget {
  final Categoria? categoria;
  final StatusChamado? status;
  final Prioridade? prioridade;
  final ValueChanged<Categoria?> onCategoria;
  final ValueChanged<StatusChamado?> onStatus;
  final ValueChanged<Prioridade?> onPrioridade;

  const ChamadosFilterBar({
    super.key,
    required this.categoria,
    required this.status,
    required this.prioridade,
    required this.onCategoria,
    required this.onStatus,
    required this.onPrioridade,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterDropdown<Categoria>(
            title: 'Categoria',
            icon: Icons.category_outlined,
            selected: categoria,
            onSelected: onCategoria,
            options: [
              for (final c in Categoria.values) FilterOption(c, c.label),
            ],
          ),
          const SizedBox(width: 10),
          FilterDropdown<StatusChamado>(
            title: 'Status',
            icon: Icons.flag_outlined,
            selected: status,
            onSelected: onStatus,
            options: [
              for (final s in StatusChamado.values) FilterOption(s, s.label),
            ],
          ),
          const SizedBox(width: 10),
          FilterDropdown<Prioridade>(
            title: 'Prioridade',
            icon: Icons.priority_high_rounded,
            selected: prioridade,
            onSelected: onPrioridade,
            options: [
              for (final p in Prioridade.values) FilterOption(p, p.label),
            ],
          ),
        ],
      ),
    );
  }
}
