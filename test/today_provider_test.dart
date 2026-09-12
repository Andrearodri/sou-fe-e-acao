import 'package:flutter_test/flutter_test.dart';
import 'package:vida_com_cristo/providers/today_provider.dart';

void main() {
  test('counts a completed day once and keeps the weekly total gentle', () {
    final provider = TodayProvider(
      nowProvider: () => DateTime(2026, 9, 12, 10),
    );

    expect(provider.completedToday, isFalse);
    expect(provider.completedDays, 0);
    provider.completeToday();
    provider.completeToday();

    expect(provider.completedToday, isTrue);
    expect(provider.completedDays, 1);
  });

  test('a completion belongs to the correct Monday to Sunday week', () {
    final provider = TodayProvider(
      nowProvider: () => DateTime(2026, 9, 7),
    );

    provider.completeToday();
    expect(provider.completedDays, 1);
    expect(provider.completedToday, isTrue);
  });
}
