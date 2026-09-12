import 'local_progress_repository.dart';

class MemoryProgressRepository implements LocalProgressRepository {
  final Set<DateTime> _completedDates = <DateTime>{};

  @override
  Future<Set<DateTime>> loadCompletedDates() async => Set.of(_completedDates);

  @override
  Future<void> saveCompletedDates(Set<DateTime> dates) async {
    _completedDates
      ..clear()
      ..addAll(dates.map(_dateOnly));
  }

  @override
  Future<void> clear() async => _completedDates.clear();

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
