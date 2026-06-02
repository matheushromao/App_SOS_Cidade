import 'package:intl/intl.dart';

/// Utilitário de formatação de datas em português do Brasil.
class DateFormatter {
  DateFormatter._();

  /// Ex.: "02/06/2026"
  static String date(DateTime value) =>
      DateFormat('dd/MM/yyyy', 'pt_BR').format(value);

  /// Ex.: "02/06/2026 às 19:54"
  static String dateTime(DateTime value) =>
      DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(value);

  /// Ex.: "19:54"
  static String time(DateTime value) =>
      DateFormat('HH:mm', 'pt_BR').format(value);

  /// Ex.: "terça-feira, 2 de junho de 2026"
  static String fullDate(DateTime value) =>
      DateFormat("EEEE, d 'de' MMMM 'de' y", 'pt_BR').format(value);

  /// Distância relativa amigável (ex.: "há 2 dias", "há 3 horas").
  static String relative(DateTime value) {
    final Duration diff = DateTime.now().difference(value);

    if (diff.inDays > 0) {
      return 'há ${diff.inDays} ${diff.inDays == 1 ? 'dia' : 'dias'}';
    }
    if (diff.inHours > 0) {
      return 'há ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
    }
    if (diff.inMinutes > 0) {
      return 'há ${diff.inMinutes} min';
    }
    return 'agora mesmo';
  }
}
