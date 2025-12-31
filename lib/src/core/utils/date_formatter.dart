import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _day = DateFormat('d MMM yyyy', 'id_ID');
  static final _month = DateFormat('MMMM yyyy', 'id_ID');

  static String day(DateTime value) => _day.format(value);
  static String month(DateTime value) => _month.format(value);
}
