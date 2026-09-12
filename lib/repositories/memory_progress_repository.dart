import '../models/daily_progress.dart';
import 'local_progress_repository.dart';

class MemoryProgressRepository implements LocalProgressRepository {
  final Set<DateTime> _completedDates = <DateTime>{};

  @override
  bool isCompleted(DateTime date) => _completedDates.contains(_dateOnly(date));

  @override
  int completedDaysInWeek(DateTime date) {
    final day = _dateOnly(date);
    final start = day.subtract(Duration(days: day.weekday - DateTime.monday));
    return List<DateTime>.generate(
      DateTime.daysPerWeek,
      (index) => start.add(Duration(days: index)),
    ).where(_completedDates.contains).length;
  }

  @override
  DailyProgress markCompleted(DateTime date) {
    final normalized = _dateOnly(date);
    _completedDates.add(normalized);
    return DailyProgress(date: normalized, completed: true);
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}
