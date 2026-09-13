import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vida_com_cristo/main.dart';
import 'package:vida_com_cristo/providers/auth_provider.dart';

import 'support/auth_fixture.dart';

void main() {
  late SupabaseClient client;
  late AuthProvider auth;
  late List<http.Request> requests;

  setUp(() {
    requests = [];
    client = fixtureClient((request) async {
      requests.add(request);
      if (request.url.path.endsWith('/signup')) {
        return jsonResponse(fixtureUser);
      }
      if (request.url.path.endsWith('/logout')) return http.Response('', 204);
      return jsonResponse(fixtureSession());
    });
    auth = AuthProvider(client: client);
  });

  tearDown(() async {
    auth.dispose();
    await client.dispose();
  });

  Future<void> showApp(WidgetTester tester) async {
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth,
      child: const MaterialApp(home: AuthWrapper(guestFirst: false)),
    ));
  }

  testWidgets('signup validates the confirmation field and explains email step',
      (tester) async {
    await showApp(tester);
    await tester.tap(find.text('Não tem conta? Criar'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Confirmar senha'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextField, 'E-mail'), fixtureEmail);
    await tester.enterText(
        find.widgetWithText(TextField, 'Senha'), fixturePassword);
    await tester.enterText(
        find.widgetWithText(TextField, 'Confirmar senha'), 'different');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pumpAndSettle();
    expect(find.text('Senhas não conferem.'), findsOneWidget);
    expect(requests, isEmpty);
    await tester.enterText(
        find.widgetWithText(TextField, 'Confirmar senha'), fixturePassword);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Criar conta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('caixa de entrada'), findsOneWidget);
    expect(find.byTooltip('Sair'), findsNothing);
  });

  for (final size in [const Size(320, 568), const Size(1440, 900)]) {
    testWidgets('login, honest home and logout at $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await showApp(tester);
      await tester.enterText(
          find.widgetWithText(TextField, 'E-mail'), fixtureEmail);
      await tester.enterText(
          find.widgetWithText(TextField, 'Senha'), fixturePassword);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('👋'), findsOneWidget);
      expect(find.text('Seu ritmo nesta semana'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Concluir rotina de hoje'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Concluir rotina de hoje'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await auth.signOut();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    });
  }

  testWidgets(
      'missing configuration is visible without Supabase initialization',
      (tester) async {
    await tester.pumpWidget(const ConfigurationErrorApp(
      message: 'Configure SUPABASE_URL e SUPABASE_ANON_KEY com --dart-define.',
    ));
    expect(find.text('Configuração necessária'), findsOneWidget);
    expect(find.textContaining('SUPABASE_URL'), findsOneWidget);
  });
}
