import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vida_com_cristo/models/devotional.dart';
import 'package:vida_com_cristo/models/local_settings.dart';
import 'package:vida_com_cristo/models/prayer_entry.dart';
import 'package:vida_com_cristo/providers/local_settings_provider.dart';
import 'package:vida_com_cristo/repositories/local_bible_repository.dart';
import 'package:vida_com_cristo/repositories/local_devotional_repository.dart';
import 'package:vida_com_cristo/repositories/local_prayer_repository.dart';
import 'package:vida_com_cristo/repositories/local_settings_repository.dart';
import 'package:vida_com_cristo/screens/bible_screen.dart';

void main() {
  test('local Bible exposes only the approved pilot books and chapters',
      () async {
    final repository = LocalBibleRepository();
    final books = await repository.loadBooks();

    expect(
      books.map((book) => book.name),
      ['João', 'Salmos', 'Provérbios'],
    );
    expect(books.map((book) => book.chapterCount), [3, 5, 3]);

    for (final book in books) {
      for (var chapter = 1; chapter <= book.chapterCount; chapter++) {
        final loaded = await repository.loadChapter(
          bookId: book.id,
          chapterNumber: chapter,
        );
        expect(loaded, isNotNull);
        expect(loaded!.verses, isNotEmpty);
      }
      expect(
        await repository.loadChapter(
          bookId: book.id,
          chapterNumber: book.chapterCount + 1,
        ),
        isNull,
      );
    }
    expect(
      await repository.loadChapter(bookId: 'nao-existe', chapterNumber: 1),
      isNull,
    );
  });

  testWidgets('Bible reader renders the pilot at a narrow viewport',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final settings = LocalSettingsProvider(
      repository: _TestSettingsRepository(),
      loadOnCreate: false,
    );
    addTearDown(settings.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: MaterialApp(
          home: BibleScreen(repository: LocalBibleRepository()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('João 1'), findsOneWidget);
    expect(find.textContaining('BLIVRE'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  test('devotionals are exactly seven, deterministic, and require review',
      () async {
    final repository = LocalDevotionalRepository();
    final all = await repository.loadAll();

    expect(all, hasLength(7));
    expect(all.map((item) => item.id).toSet(), hasLength(7));
    expect(
      all.every((item) => item.status == EditorialStatus.reviewRequired),
      isTrue,
    );

    final date = DateTime(2026, 9, 12, 9);
    final first = await repository.forDate(date);
    final second = await repository.forDate(DateTime(2026, 9, 12, 23));
    expect(first?.id, second?.id);
    expect(all.any((item) => item.id == first?.id), isTrue);
  });

  test('private prayer repository supports CRUD and answered state', () async {
    final store = _MemorySecureValueStore();
    final repository = LocalPrayerRepository(store: store);
    final createdAt = DateTime(2026, 9, 12, 10);
    final entry = PrayerEntry(
      id: 'prayer-1',
      title: 'Trabalho',
      content: 'Um pedido privado de teste.',
      createdAt: createdAt,
      updatedAt: createdAt,
      answeredAt: null,
      isAnswered: false,
    );

    await repository.save(entry);
    final restored = (await repository.loadAll()).single;
    expect(restored.id, entry.id);
    expect(restored.title, entry.title);
    expect(restored.content, entry.content);
    expect(restored.createdAt, entry.createdAt);

    final answeredAt = DateTime(2026, 9, 13, 10);
    await repository.save(entry.copyWith(
      updatedAt: answeredAt,
      answeredAt: answeredAt,
      isAnswered: true,
    ));
    final answered = (await repository.loadAll()).single;
    expect(answered.isAnswered, isTrue);
    expect(answered.answeredAt, answeredAt);

    await repository.delete(entry.id);
    expect(await repository.loadAll(), isEmpty);
  });

  test('secure storage failure is surfaced without plaintext fallback',
      () async {
    final store = _MemorySecureValueStore()..fail = true;
    final repository = LocalPrayerRepository(store: store);
    final entry = PrayerEntry(
      id: 'prayer-failure',
      title: 'Não persistir',
      content: 'Não deve ser mantido em fallback inseguro.',
      createdAt: DateTime(2026, 9, 12),
      updatedAt: DateTime(2026, 9, 12),
      answeredAt: null,
      isAnswered: false,
    );

    await expectLater(repository.save(entry), throwsA(isA<StateError>()));
    expect(store.value, isNull);
    await expectLater(repository.loadAll(), throwsA(isA<StateError>()));
  });
}

class _MemorySecureValueStore implements SecureValueStore {
  String? value;
  bool fail = false;

  @override
  Future<String?> read(String key) async {
    if (fail) throw StateError('secure storage unavailable');
    return value;
  }

  @override
  Future<void> write(String key, String value) async {
    if (fail) throw StateError('secure storage unavailable');
    this.value = value;
  }

  @override
  Future<void> delete(String key) async {
    if (fail) throw StateError('secure storage unavailable');
    value = null;
  }
}

class _TestSettingsRepository implements LocalSettingsRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<LocalSettings> load() async => LocalSettings.defaults;

  @override
  Future<void> save(LocalSettings settings) async {}
}
