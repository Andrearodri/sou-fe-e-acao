import 'package:shared_preferences/shared_preferences.dart';

import 'local_progress_repository.dart';

class SharedPreferencesProgressRepository implements LocalProgressRepository {
  static const _completedDatesKey = 'vida_com_cristo.completed_dates';

  @override
  Future<Set<DateTime>> loadCompletedDates() async {
    final preferences = await SharedPreferences.getInstance();
    final values = preferences.getStringList(_completedDatesKey) ?? const [];
    return values
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .map(_dateOnly)
        .toSet();
  }

  @override
  Future<void> saveCompletedDates(Set<DateTime> dates) async {
    final preferences = await SharedPreferences.getInstance();
    final values = dates.map(_dateKey).toList()..sort();
    await preferences.setStringList(_completedDatesKey, values);
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_completedDatesKey);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _dateKey(DateTime date) {
    final normalized = _dateOnly(date);
    return '${normalized.year.toString().padLeft(4, '0')}-'
        '${normalized.month.toString().padLeft(2, '0')}-'
        '${normalized.day.toString().padLeft(2, '0')}';
  }
}
