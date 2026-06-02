/// Constantes globais e textos fixos da aplicação SOS Cidade.
class AppConstants {
  AppConstants._();

  /// Nome exibido em toda a aplicação.
  static const String appName = 'SOS Cidade';

  /// Subtítulo institucional exibido no cabeçalho.
  static const String appTagline = 'Canal de atendimento à população';

  /// Texto padrão do campo de busca.
  static const String searchHint = 'Buscar chamado pelo título...';

  /// Rótulo usado quando nenhum filtro está selecionado.
  static const String filterAll = 'Todos';

  /// Mensagem exibida quando a lista filtrada fica vazia.
  static const String emptyListMessage =
      'Nenhum chamado encontrado para os filtros selecionados.';

  /// Espaçamento padrão de layout (em pixels lógicos).
  static const double spacing = 16.0;

  /// Raio padrão de cantos arredondados.
  static const double borderRadius = 16.0;

  /// Larguras de referência para responsividade.
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  /// Largura máxima do conteúdo em telas muito largas (web/desktop).
  static const double maxContentWidth = 1280.0;
}
