import 'package:flutter/foundation.dart';

import '../repositories/local_progress_repository.dart';
import '../repositories/memory_progress_repository.dart';

class TodayProvider extends ChangeNotifier {
  TodayProvider({
    LocalProgressRepository? repository,
    DateTime Function()? nowProvider,
  })  : _repository = repository ?? MemoryProgressRepository(),
        _nowProvider = nowProvider ?? DateTime.now {
    _refresh();
  }

  final LocalProgressRepository _repository;
  final DateTime Function() _nowProvider;
  late DateTime _now;
  late bool _completedToday;
  late int _completedDays;

  DateTime get now => _now;
  bool get completedToday => _completedToday;
  int get completedDays => _completedDays;

  void completeToday() {
    if (_completedToday) return;
    _repository.markCompleted(_now);
    _refresh();
    notifyListeners();
  }

  void refresh() {
    _refresh();
    notifyListeners();
  }

  void _refresh() {
    _now = _nowProvider();
    _completedToday = _repository.isCompleted(_now);
    _completedDays = _repository.completedDaysInWeek(_now);
  }
}
