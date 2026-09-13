import '../models/devotional.dart';

abstract interface class DevotionalRepository {
  Future<List<Devotional>> loadAll();

  Future<Devotional?> forDate(DateTime date);
}
