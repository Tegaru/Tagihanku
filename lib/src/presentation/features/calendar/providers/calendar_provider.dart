import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarState {
  const CalendarState({
    required this.month,
  });

  final DateTime month;

  CalendarState copyWith({DateTime? month}) {
    return CalendarState(month: month ?? this.month);
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier();
});

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier() : super(CalendarState(month: DateTime.now()));

  void nextMonth() {
    final date = DateTime(state.month.year, state.month.month + 1);
    state = state.copyWith(month: date);
  }

  void previousMonth() {
    final date = DateTime(state.month.year, state.month.month - 1);
    state = state.copyWith(month: date);
  }
}
