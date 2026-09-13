import '../models/prayer_entry.dart';

abstract interface class PrayerRepository {
  Future<List<PrayerEntry>> loadAll();

  Future<void> save(PrayerEntry entry);

  Future<void> delete(String id);

  Future<void> clear();
}
