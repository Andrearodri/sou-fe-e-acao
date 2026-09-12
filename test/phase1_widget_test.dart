import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vida_com_cristo/main.dart';
import 'package:vida_com_cristo/screens/app_shell.dart';
import 'package:vida_com_cristo/providers/auth_provider.dart';

void main() {
  testWidgets('public app opens without Supabase configuration', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('👋'), findsOneWidget);
    await tester.tap(find.text('Mais'));
    await tester.pumpAndSettle();
    expect(find.text('Modo visitante'), findsOneWidget);
    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark);
  });

  testWidgets('guest can navigate through the four MVP areas', (tester) async {
    final auth = AuthProvider();
    addTearDown(auth.dispose);

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth,
      child: const MaterialApp(home: AppShell()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('👋'), findsOneWidget);
    expect(find.text('DEVOCIONAL PROVISÓRIO'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('VERSÍCULO PROVISÓRIO'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
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

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth,
      child: const MaterialApp(home: AppShell()),
    ));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Concluir rotina de hoje'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Concluir rotina de hoje'));
    await tester.pumpAndSettle();
    expect(find.text('Rotina concluída hoje'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Rotina concluída hoje'),
        findsOneWidget);
  });
}
