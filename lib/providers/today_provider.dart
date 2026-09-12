import 'dart:async';

import 'package:flutter/foundation.dart';

import '../repositories/local_progress_repository.dart';
import '../repositories/shared_preferences_progress_repository.dart';

class TodayProvider extends ChangeNotifier {
  TodayProvider({
    LocalProgressRepository? repository,
    DateTime Function()? nowProvider,
    bool loadOnCreate = true,
  })  : _repository = repository ?? SharedPreferencesProgressRepository(),
        _nowProvider = nowProvider ?? DateTime.now {
    _refresh();
    if (loadOnCreate) unawaited(load());
  }

  final LocalProgressRepository _repository;
  final DateTime Function() _nowProvider;
  Set<DateTime> _completedDates = <DateTime>{};
  bool _hasLocalMutations = false;
  bool _disposed = false;
  late DateTime _now;
  late bool _completedToday;
  late int _completedDays;

  DateTime get now => _now;
  bool get completedToday => _completedToday;
  int get completedDays => _completedDays;

  Future<void> load() async {
    try {
      final dates = await _repository.loadCompletedDates();
      if (!_hasLocalMutations) _completedDates = dates.map(_dateOnly).toSet();
    } catch (_) {
      if (!_hasLocalMutations) _completedDates = <DateTime>{};
    }
    _refresh();
    _notify();
  }

  Future<void> completeToday() async {
    if (_completedToday) return;
    _hasLocalMutations = true;
    _completedDates.add(_dateOnly(_now));
    _refresh();
    _notify();
    await _persist();
  }

  Future<void> clear() async {
    _hasLocalMutations = true;
    _completedDates = <DateTime>{};
    _refresh();
    _notify();
    try {
      await _repository.clear();
    } catch (_) {
      // Local storage is optional for the guest experience.
    }
  }

  void refresh() {
    _refresh();
    _notify();
  }

  void _refresh() {
    _now = _nowProvider();
    _completedToday = _completedDates.contains(_dateOnly(_now));
    final currentDay = _dateOnly(_now);
    final startOfWeek = currentDay.subtract(
      Duration(days: currentDay.weekday - DateTime.monday),
    );
    _completedDays = List<DateTime>.generate(
      DateTime.daysPerWeek,
      (index) => startOfWeek.add(Duration(days: index)),
    ).where(_completedDates.contains).length;
  }

  Future<void> _persist() async {
    try {
      await _repository.saveCompletedDates(_completedDates);
    } catch (_) {
      // The in-session result stays available if local storage is unavailable.
    }
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
