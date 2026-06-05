import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AlertaCriticos extends StatelessWidget {
  final int quantidadeCriticos;

  const AlertaCriticos({super.key, required this.quantidadeCriticos});

  @override
  Widget build(BuildContext context) {
    if (quantidadeCriticos <= 5) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.danger, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Atenção: Situação Crítica',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '$quantidadeCriticos chamados críticos em aberto. Ação imediata necessária.',
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
