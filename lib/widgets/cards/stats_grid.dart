import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../services/chamado_service.dart';
import 'stat_card.dart';

/// Grade responsiva com os quatro cards de estatísticas do Dashboard.
class StatsGrid extends StatelessWidget {
  final ChamadoEstatisticas estatisticas;

  const StatsGrid({super.key, required this.estatisticas});

  @override
  Widget build(BuildContext context) {
    final int columns = Responsive.statColumns(context);

    final cards = <Widget>[
      StatCard(
        title: 'Abertos',
        value: estatisticas.abertos,
        icon: Icons.fiber_new_outlined,
        color: AppColors.primary,
      ),
      StatCard(
        title: 'Em Andamento',
        value: estatisticas.emAndamento,
        icon: Icons.autorenew_rounded,
        color: AppColors.warning,
      ),
      StatCard(
        title: 'Concluídos',
        value: estatisticas.concluidos,
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ),
      StatCard(
        title: 'Críticos',
        value: estatisticas.criticos,
        icon: Icons.priority_high_rounded,
        color: AppColors.danger,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        // Altura fixa garante que o conteúdo do card nunca estoure,
        // independentemente da largura da tela (mobile, tablet ou web).
        mainAxisExtent: 150,
      ),
      itemBuilder: (context, index) => cards[index],
    );
  }
}
