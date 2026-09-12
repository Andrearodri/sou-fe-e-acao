import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vida_com_cristo/models/local_settings.dart';
import 'package:vida_com_cristo/providers/auth_provider.dart';
import 'package:vida_com_cristo/providers/local_settings_provider.dart';
import 'package:vida_com_cristo/providers/today_provider.dart';
import 'package:vida_com_cristo/repositories/local_progress_repository.dart';
import 'package:vida_com_cristo/repositories/local_settings_repository.dart';
import 'package:vida_com_cristo/repositories/shared_preferences_progress_repository.dart';
import 'package:vida_com_cristo/repositories/shared_preferences_settings_repository.dart';

import 'support/auth_fixture.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('local display name persists and an empty name remains optional',
      () async {
    final repository = SharedPreferencesSettingsRepository();
    final first = LocalSettingsProvider(
      repository: repository,
      loadOnCreate: false,
    );
    await first.load();
    await first.setDisplayName('  Ana  ');

    final restored = LocalSettingsProvider(
      repository: repository,
      loadOnCreate: false,
    );
    await restored.load();
    expect(restored.displayName, 'Ana');

    await restored.setDisplayName('');
    final withoutName = LocalSettingsProvider(
      repository: repository,
      loadOnCreate: false,
    );
    await withoutName.load();
    expect(withoutName.displayName, isEmpty);

    first.dispose();
    restored.dispose();
    withoutName.dispose();
  });

  test('theme preference persists locally', () async {
    final repository = SharedPreferencesSettingsRepository();
    final first = LocalSettingsProvider(
      repository: repository,
      loadOnCreate: false,
    );
    await first.setThemePreference(AppThemePreference.dark);

    final restored = LocalSettingsProvider(
      repository: repository,
      loadOnCreate: false,
    );
    await restored.load();
    expect(restored.themePreference, AppThemePreference.dark);

    first.dispose();
    restored.dispose();
  });

  test('editorial text size persists locally', () async {
    final repository = SharedPreferencesSettingsRepository();
    final first = LocalSettingsProvider(
      repository: repository,
      loadOnCreate: false,
    );
    await first.setEditorialFontSize(EditorialFontSize.large);

    final restored = LocalSettingsProvider(
      repository: repository,
      loadOnCreate: false,
    );
    await restored.load();
    expect(restored.editorialFontSize, EditorialFontSize.large);
    expect(restored.editorialFontScale, 1.15);

    first.dispose();
    restored.dispose();
  });

  test('completed local days persist and the same day is never duplicated',
      () async {
    final repository = SharedPreferencesProgressRepository();
    final first = TodayProvider(
      repository: repository,
      nowProvider: () => DateTime(2026, 9, 12, 10),
      loadOnCreate: false,
    );
    await first.load();
    await first.completeToday();
    await first.completeToday();

    final restored = TodayProvider(
      repository: repository,
      nowProvider: () => DateTime(2026, 9, 12, 18),
      loadOnCreate: false,
    );
    await restored.load();
    expect(restored.completedToday, isTrue);
    expect(restored.completedDays, 1);

    first.dispose();
    restored.dispose();
  });

  test('a new week keeps stored history while recalculating the weekly total',
      () async {
    final repository = SharedPreferencesProgressRepository();
    final completedOnSunday = TodayProvider(
      repository: repository,
      nowProvider: () => DateTime(2026, 9, 13, 10),
      loadOnCreate: false,
    );
    await completedOnSunday.load();
    await completedOnSunday.completeToday();

    final followingWeek = TodayProvider(
      repository: repository,
      nowProvider: () => DateTime(2026, 9, 14, 10),
      loadOnCreate: false,
    );
    await followingWeek.load();
    expect(followingWeek.completedDays, 0);
    expect((await repository.loadCompletedDates()), hasLength(1));

    completedOnSunday.dispose();
    followingWeek.dispose();
  });

  test('clearing local providers restores defaults', () async {
    final settingsRepository = SharedPreferencesSettingsRepository();
    final progressRepository = SharedPreferencesProgressRepository();
    final settings = LocalSettingsProvider(
      repository: settingsRepository,
      loadOnCreate: false,
    );
    final progress = TodayProvider(
      repository: progressRepository,
      nowProvider: () => DateTime(2026, 9, 12),
      loadOnCreate: false,
    );
    await settings.setDisplayName('Ana');
    await settings.setThemePreference(AppThemePreference.dark);
    await settings.setEditorialFontSize(EditorialFontSize.large);
    await progress.completeToday();

    await settings.clear();
    await progress.clear();

    final restoredSettings = LocalSettingsProvider(
      repository: settingsRepository,
      loadOnCreate: false,
    );
    final restoredProgress = TodayProvider(
      repository: progressRepository,
      nowProvider: () => DateTime(2026, 9, 12),
      loadOnCreate: false,
    );
    await restoredSettings.load();
    await restoredProgress.load();
    expect(restoredSettings.displayName, isEmpty);
    expect(restoredSettings.themePreference, AppThemePreference.system);
    expect(restoredSettings.editorialFontSize, EditorialFontSize.standard);
    expect(restoredProgress.completedDays, 0);

    settings.dispose();
    progress.dispose();
    restoredSettings.dispose();
    restoredProgress.dispose();
  });

  test('storage failures fall back to guest-safe defaults', () async {
    final settings = LocalSettingsProvider(
      repository: _FailingSettingsRepository(),
      loadOnCreate: false,
    );
    final progress = TodayProvider(
      repository: _FailingProgressRepository(),
      nowProvider: () => DateTime(2026, 9, 12),
      loadOnCreate: false,
    );

    await settings.load();
    await progress.load();
    expect(settings.displayName, isEmpty);
    expect(settings.themePreference, AppThemePreference.system);
    expect(progress.completedDays, 0);
    expect(progress.completedToday, isFalse);

    settings.dispose();
    progress.dispose();
  });

  test('clearing local data does not call remote logout', () async {
    final requests = <http.Request>[];
    final client = fixtureClient((request) async {
      requests.add(request);
      if (request.url.path.endsWith('/logout')) return http.Response('', 204);
      return jsonResponse(fixtureSession());
    });
    final auth = AuthProvider(client: client);
    final settings = LocalSettingsProvider(
      repository: SharedPreferencesSettingsRepository(),
      loadOnCreate: false,
    );
    final progress = TodayProvider(
      repository: SharedPreferencesProgressRepository(),
      nowProvider: () => DateTime(2026, 9, 12),
      loadOnCreate: false,
    );
    addTearDown(() async {
      auth.dispose();
      settings.dispose();
      progress.dispose();
      await client.dispose();
    });

    await settings.setDisplayName('Ana');
    await progress.completeToday();
    await auth.signIn(fixtureEmail, fixturePassword);
    requests.clear();

    await settings.clear();
    await progress.clear();

    expect(auth.isAuthenticated, isTrue);
    expect(requests.where((request) => request.url.path.endsWith('/logout')),
        isEmpty);
    expect(settings.displayName, isEmpty);
    expect(progress.completedDays, 0);
  });
}

class _FailingSettingsRepository implements LocalSettingsRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<LocalSettings> load() => Future.error(StateError('storage failed'));

  @override
  Future<void> save(LocalSettings settings) async {}
}

class _FailingProgressRepository implements LocalProgressRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<Set<DateTime>> loadCompletedDates() =>
      Future.error(StateError('storage failed'));

  @override
  Future<void> saveCompletedDates(Set<DateTime> dates) async {}
}
