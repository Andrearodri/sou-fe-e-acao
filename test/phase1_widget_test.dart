import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vida_com_cristo/main.dart';
import 'package:vida_com_cristo/models/local_settings.dart';
import 'package:vida_com_cristo/providers/auth_provider.dart';
import 'package:vida_com_cristo/providers/local_settings_provider.dart';
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
    expect(find.text('DEVOCIONAL PROVISÓRIO'), findsOneWidget);
    await _scrollPage(tester);
    expect(find.text('VERSÍCULO PROVISÓRIO'), findsOneWidget);

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
}

Widget _buildAppShell(AuthProvider auth) {
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
      home: AppShell(progressRepository: MemoryProgressRepository()),
    ),
  );
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
