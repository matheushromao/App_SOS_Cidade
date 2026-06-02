import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../models/chamado.dart';
import '../cards/chamado_card.dart';
import '../common/empty_state.dart';

/// Lista responsiva de chamados.
///
/// Em celulares e tablets exibe uma única coluna; em telas largas
/// (desktop/web) distribui os cards em duas colunas para melhor
/// aproveitamento do espaço. Não rola sozinha — espera-se que esteja
/// dentro de um scroll externo (ex.: CustomScrollView).
class ChamadosList extends StatelessWidget {
  final List<Chamado> chamados;
  final ValueChanged<Chamado> onTapChamado;

  const ChamadosList({
    super.key,
    required this.chamados,
    required this.onTapChamado,
  });

  @override
  Widget build(BuildContext context) {
    if (chamados.isEmpty) {
      return const EmptyState(message: AppConstants.emptyListMessage);
    }

    final int columns = Responsive.listColumns(context);

    if (columns == 1) {
      return Column(
        children: [
          for (final chamado in chamados) ...[
            ChamadoCard(
              chamado: chamado,
              onTap: () => onTapChamado(chamado),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    // Layout em grade para telas largas.
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: chamados.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 210,
      ),
      itemBuilder: (context, index) {
        final chamado = chamados[index];
        return ChamadoCard(
          chamado: chamado,
          onTap: () => onTapChamado(chamado),
        );
      },
    );
  }
}
