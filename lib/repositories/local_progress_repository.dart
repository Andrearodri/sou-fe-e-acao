import '../models/daily_progress.dart';

abstract class LocalProgressRepository {
  bool isCompleted(DateTime date);
  int completedDaysInWeek(DateTime date);
  DailyProgress markCompleted(DateTime date);
}
