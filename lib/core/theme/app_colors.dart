import 'package:flutter/material.dart';

/// Paleta de cores institucional do SOS Cidade.
///
/// Centraliza todas as cores usadas na aplicação para garantir
/// consistência visual e facilitar manutenção do tema.
class AppColors {
  AppColors._();

  /// Azul institucional — cor primária da prefeitura.
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF5E92F3);

  /// Verde — usado para chamados concluídos.
  static const Color success = Color(0xFF2E7D32);

  /// Laranja — usado para chamados em andamento.
  static const Color warning = Color(0xFFEF6C00);

  /// Vermelho — usado para chamados críticos.
  static const Color danger = Color(0xFFC62828);

  /// Cinza — usado para informações neutras e ícones secundários.
  static const Color neutral = Color(0xFF607D8B);

  /// Fundo geral da aplicação (tema claro).
  static const Color background = Color(0xFFF4F6F9);
  static const Color surface = Colors.white;

  /// Tons de texto (tema claro).
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF5C6670);

  // --- Tema escuro ---------------------------------------------------------
  static const Color primaryDarkMode = Color(0xFF82B1FF);
  static const Color backgroundDark = Color(0xFF121417);
  static const Color surfaceDark = Color(0xFF1C1F24);
  static const Color textPrimaryDark = Color(0xFFE6E8EA);
  static const Color textSecondaryDark = Color(0xFF9AA3AD);
}
