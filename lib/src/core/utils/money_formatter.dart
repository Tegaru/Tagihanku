import 'package:intl/intl.dart';

class MoneyFormatter {
  MoneyFormatter._();

  static final _formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  static String format(int amount) => _formatter.format(amount);
}
