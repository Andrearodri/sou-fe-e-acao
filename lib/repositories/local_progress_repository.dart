abstract class LocalProgressRepository {
  Future<Set<DateTime>> loadCompletedDates();
  Future<void> saveCompletedDates(Set<DateTime> dates);
  Future<void> clear();
}
