import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vida_com_cristo/main.dart';
import 'package:vida_com_cristo/models/devotional.dart';
import 'package:vida_com_cristo/models/local_settings.dart';
import 'package:vida_com_cristo/providers/auth_provider.dart';
import 'package:vida_com_cristo/providers/local_settings_provider.dart';
import 'package:vida_com_cristo/repositories/devotional_repository.dart';
import 'package:vida_com_cristo/repositories/local_settings_repository.dart';
import 'package:vida_com_cristo/repositories/memory_progress_repository.dart';
import 'package:vida_com_cristo/screens/app_shell.dart';

void main() {
  testWidgets('public app opens without Supabase configuration',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MyApp(
        settingsRepository: _MemorySettingsRepository(),
        progressRepository: MemoryProgressRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('👋'), findsOneWidget);
    await tester.tap(find.text('Mais'));
    await tester.pumpAndSettle();
    expect(find.text('Modo visitante'), findsOneWidget);
  });

  testWidgets('guest can navigate through the four MVP areas', (tester) async {
    final auth = AuthProvider();
    addTearDown(auth.dispose);

    await tester.pumpWidget(_buildAppShell(auth));
    await tester.pumpAndSettle();

    expect(find.textContaining('👋'), findsOneWidget);
    expect(find.textContaining('DEVOCIONAL PROVISÓRIO'), findsOneWidget);
    await _scrollPage(tester);
    expect(find.textContaining('VERSÍCULO PROVISÓRIO'), findsOneWidget);

    for (final label in ['Bíblia', 'Orações', 'Mais', 'Hoje']) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(find.text(label), findsWidgets);
      if (label == 'Mais') {
        expect(find.text('Modo visitante'), findsOneWidget);
      }
    }
  });

  testWidgets('routine completion is idempotent during the session',
      (tester) async {
    final auth = AuthProvider();
    addTearDown(auth.dispose);

    await tester.pumpWidget(_buildAppShell(auth));
    await tester.pumpAndSettle();

    await _scrollPage(tester, times: 2);
    await tester.tap(find.text('Concluir rotina de hoje'));
    await tester.pumpAndSettle();
    expect(find.text('Rotina concluída hoje'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Rotina concluída hoje'),
        findsOneWidget);
  });

  testWidgets('daily-03 opens Provérbios 3 from Hoje', (tester) async {
    final auth = AuthProvider();
    addTearDown(auth.dispose);

    await tester.pumpWidget(_buildAppShell(
      auth,
      devotionalRepository: _FixedDevotionalRepository(_devotional(
        id: 'daily-03',
        bookId: 'proverbios',
        chapterNumber: 3,
        verseNumber: 5,
        bibleReference: 'Provérbios 3:5',
        verseReference: 'Provérbios 3:5',
      )),
    ));
    await tester.pumpAndSettle();

    await _openBibleFromHome(tester);

    expect(find.text('Provérbios 3'), findsOneWidget);
  });

  testWidgets('daily-07 opens João 3 from Hoje', (tester) async {
    final auth = AuthProvider();
    addTearDown(auth.dispose);

    await tester.pumpWidget(_buildAppShell(
      auth,
      devotionalRepository: _FixedDevotionalRepository(_devotional(
        id: 'daily-07',
        bookId: 'joao',
        chapterNumber: 3,
        verseNumber: 16,
        bibleReference: 'João 3:16',
        verseReference: 'João 3:16',
      )),
    ));
    await tester.pumpAndSettle();

    await _openBibleFromHome(tester);

    expect(find.text('João 3'), findsOneWidget);
  });

  testWidgets('approved devotional does not show review warning',
      (tester) async {
    final auth = AuthProvider();
    addTearDown(auth.dispose);

    await tester.pumpWidget(_buildAppShell(
      auth,
      devotionalRepository: _FixedDevotionalRepository(_devotional(
        id: 'approved',
        bookId: 'proverbios',
        chapterNumber: 3,
        verseNumber: 5,
        bibleReference: 'Provérbios 3:5',
        verseReference: 'Provérbios 3:5',
        status: EditorialStatus.approved,
      )),
    ));
    await tester.pumpAndSettle();

    expect(find.text('DEVOCIONAL PROVISÓRIO • APROVADO'), findsOneWidget);
    expect(find.text('DEVOCIONAL PROVISÓRIO • REVISÃO HUMANA PENDENTE'),
        findsNothing);
  });

  testWidgets('review-required devotional keeps review warning',
      (tester) async {
    final auth = AuthProvider();
    addTearDown(auth.dispose);

    await tester.pumpWidget(_buildAppShell(
      auth,
      devotionalRepository: _FixedDevotionalRepository(_devotional(
        id: 'review-required',
        bookId: 'proverbios',
        chapterNumber: 3,
        verseNumber: 5,
        bibleReference: 'Provérbios 3:5',
        verseReference: 'Provérbios 3:5',
        status: EditorialStatus.reviewRequired,
      )),
    ));
    await tester.pumpAndSettle();

    expect(find.text('DEVOCIONAL PROVISÓRIO • REVISÃO HUMANA PENDENTE'),
        findsOneWidget);
  });
}

Future<void> _openBibleFromHome(WidgetTester tester) async {
  final button = find.widgetWithText(OutlinedButton, 'Abrir Bíblia');
  await _scrollPage(tester, times: 2);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Widget _buildAppShell(
  AuthProvider auth, {
  DevotionalRepository? devotionalRepository,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider(
        create: (_) => LocalSettingsProvider(
          repository: _MemorySettingsRepository(),
        ),
      ),
    ],
    child: MaterialApp(
      home: AppShell(
        progressRepository: MemoryProgressRepository(),
        devotionalRepository: devotionalRepository,
      ),
    ),
  );
}

Devotional _devotional({
  required String id,
  required String bookId,
  required int chapterNumber,
  required int verseNumber,
  required String bibleReference,
  required String verseReference,
  EditorialStatus status = EditorialStatus.approved,
}) {
  return Devotional(
    id: id,
    title: 'Devocional de teste',
    bibleReference: bibleReference,
    verseReference: verseReference,
    bookId: bookId,
    chapterNumber: chapterNumber,
    verseNumber: verseNumber,
    reflection: 'Reflexão de teste.',
    application: 'Aplicação de teste.',
    prayer: null,
    status: status,
  );
}

class _FixedDevotionalRepository implements DevotionalRepository {
  _FixedDevotionalRepository(this.devotional);

  final Devotional devotional;

  @override
  Future<Devotional?> forDate(DateTime date) async => devotional;

  @override
  Future<List<Devotional>> loadAll() async => [devotional];
}

Future<void> _scrollPage(WidgetTester tester, {int times = 1}) async {
  for (var index = 0; index < times; index++) {
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pump();
  }
}

class _MemorySettingsRepository implements LocalSettingsRepository {
  LocalSettings _settings = LocalSettings.defaults;

  @override
  Future<void> clear() async => _settings = LocalSettings.defaults;

  @override
  Future<LocalSettings> load() async => _settings;

  @override
  Future<void> save(LocalSettings settings) async => _settings = settings;
}
