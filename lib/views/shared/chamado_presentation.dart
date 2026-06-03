import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/chamado.dart';

/// Mapeamento visual (cor + ícone) dos enums de domínio.
///
/// Fica na camada de View para que o model permaneça puro (sem Flutter).
/// As Views consomem `categoria.icone`, `status.cor`, etc. exatamente como
/// se fossem propriedades do enum, graças a estas extensions.
extension CategoriaVisual on Categoria {
  IconData get icone {
    switch (this) {
      case Categoria.buraco:
        return Icons.warning_amber_rounded;
      case Categoria.iluminacao:
        return Icons.lightbulb_outline;
      case Categoria.vazamento:
        return Icons.water_drop_outlined;
      case Categoria.acidente:
        return Icons.car_crash_outlined;
      case Categoria.semaforo:
        return Icons.traffic_outlined;
      case Categoria.lixo:
        return Icons.delete_outline;
      case Categoria.arvore:
        return Icons.park_outlined;
      case Categoria.enchente:
        return Icons.flood_outlined;
    }
  }
}

extension PrioridadeVisual on Prioridade {
  Color get cor {
    switch (this) {
      case Prioridade.baixa:
        return AppColors.neutral;
      case Prioridade.media:
        return AppColors.primary;
      case Prioridade.alta:
        return AppColors.warning;
      case Prioridade.critica:
        return AppColors.danger;
    }
  }
}

extension StatusVisual on StatusChamado {
  Color get cor {
    switch (this) {
      case StatusChamado.aberto:
        return AppColors.primary;
      case StatusChamado.emAndamento:
        return AppColors.warning;
      case StatusChamado.concluido:
        return AppColors.success;
    }
  }

  IconData get icone {
    switch (this) {
      case StatusChamado.aberto:
        return Icons.fiber_new_outlined;
      case StatusChamado.emAndamento:
        return Icons.autorenew_rounded;
      case StatusChamado.concluido:
        return Icons.check_circle_outline;
    }
  }
}
