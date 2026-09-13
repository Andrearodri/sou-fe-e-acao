import '../content/local_devotionals.dart';
import '../models/devotional.dart';
import 'devotional_repository.dart';

class LocalDevotionalRepository implements DevotionalRepository {
  @override
  Future<List<Devotional>> loadAll() async => localDevotionals;

  @override
  Future<Devotional?> forDate(DateTime date) async {
    if (localDevotionals.isEmpty) return null;
    final normalized = DateTime(date.year, date.month, date.day);
    final firstDay = DateTime(2024, 1, 1);
    final offset = normalized.difference(firstDay).inDays;
    final index = offset.remainder(localDevotionals.length);
    return localDevotionals[
        index < 0 ? index + localDevotionals.length : index];
  }
}
