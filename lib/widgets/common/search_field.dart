import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Campo de busca reutilizável com botão de limpar.
class SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String value;

  const SearchField({
    super.key,
    required this.onChanged,
    required this.onClear,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: AppConstants.searchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Limpar busca',
                onPressed: onClear,
              )
            : null,
      ),
    );
  }
}
