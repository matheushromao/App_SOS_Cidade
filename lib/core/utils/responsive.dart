import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';

/// Classificação de tamanho de tela usada para layout adaptativo.
enum DeviceType { mobile, tablet, desktop }

/// Utilitários de responsividade compartilhados entre as telas.
///
/// Centraliza os breakpoints e cálculos de colunas para manter o
/// comportamento consistente em celulares, tablets e navegadores web.
class Responsive {
  Responsive._();

  static DeviceType deviceType(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= AppConstants.tabletBreakpoint) return DeviceType.desktop;
    if (width >= AppConstants.mobileBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      deviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      deviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      deviceType(context) == DeviceType.desktop;

  /// Número de colunas para a grade de cards de estatísticas.
  static int statColumns(BuildContext context) {
    switch (deviceType(context)) {
      case DeviceType.desktop:
        return 4;
      case DeviceType.tablet:
        return 4;
      case DeviceType.mobile:
        return 2;
    }
  }

  /// Define se a lista de chamados deve ser exibida em duas colunas.
  static int listColumns(BuildContext context) =>
      isDesktop(context) ? 2 : 1;

  /// Padding horizontal externo da tela conforme o dispositivo.
  static double horizontalPadding(BuildContext context) {
    switch (deviceType(context)) {
      case DeviceType.desktop:
        return 32;
      case DeviceType.tablet:
        return 24;
      case DeviceType.mobile:
        return 16;
    }
  }
}
