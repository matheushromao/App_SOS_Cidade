import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

/// Item exibido em um [FilterDropdown].
class FilterOption<T> {
  final T value;
  final String label;

  const FilterOption(this.value, this.label);
}

/// Filtro em formato de chip com menu suspenso.
///
/// Genérico: pode filtrar por categoria, status ou prioridade.
/// O valor `null` representa "sem filtro" (todos os itens).
class FilterDropdown<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final T? selected;
  final List<FilterOption<T>> options;
  final ValueChanged<T?> onSelected;

  const FilterDropdown({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = selected != null;
    final String currentLabel = active
        ? options.firstWhere((o) => o.value == selected).label
        : title;

    return PopupMenuButton<T?>(
      tooltip: 'Filtrar por $title',
      onSelected: onSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<T?>(
          value: null,
          child: _menuRow(AppConstants.filterAll, selected == null),
        ),
        const PopupMenuDivider(),
        ...options.map(
          (o) => PopupMenuItem<T?>(
            value: o.value,
            child: _menuRow(o.label, o.value == selected),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active
                ? AppColors.primary
                : Colors.black.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              currentLabel,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_drop_down,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuRow(String label, bool isSelected) {
    return Row(
      children: [
        Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          size: 18,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
