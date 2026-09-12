import 'package:flutter_test/flutter_test.dart';
import 'package:vida_com_cristo/providers/today_provider.dart';
import 'package:vida_com_cristo/repositories/memory_progress_repository.dart';

void main() {
  test('counts a completed day once and keeps the weekly total gentle',
      () async {
    final provider = TodayProvider(
      repository: MemoryProgressRepository(),
      nowProvider: () => DateTime(2026, 9, 12, 10),
      loadOnCreate: false,
    );
    await provider.load();

    expect(provider.completedToday, isFalse);
    expect(provider.completedDays, 0);
    await provider.completeToday();
    await provider.completeToday();

    expect(provider.completedToday, isTrue);
    expect(provider.completedDays, 1);
  });

  test('a completion belongs to the correct Monday to Sunday week', () async {
    final provider = TodayProvider(
      repository: MemoryProgressRepository(),
      nowProvider: () => DateTime(2026, 9, 7),
      loadOnCreate: false,
    );

    await provider.completeToday();
    expect(provider.completedDays, 1);
    expect(provider.completedToday, isTrue);
  });
}
