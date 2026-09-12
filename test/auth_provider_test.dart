import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vida_com_cristo/providers/auth_provider.dart';

import 'support/auth_fixture.dart';

void main() {
  late SupabaseClient client;
  late AuthProvider auth;
  late Future<http.Response> Function(http.Request) handler;
  late List<http.Request> requests;

  setUp(() {
    requests = [];
    handler = (_) async => jsonResponse(fixtureSession());
    client = fixtureClient((request) {
      requests.add(request);
      return handler(request);
    });
    auth = AuthProvider(
      client: client,
      baseUriProvider: () => Uri.parse('https://soufeeacao.pages.dev/'),
    );
  });

  tearDown(() async {
    auth.dispose();
    await client.dispose();
  });

  test('all signup validation failures are blocked before HTTP', () async {
    for (final input in [
      ['', fixturePassword, fixturePassword],
      ['invalid', fixturePassword, fixturePassword],
      [fixtureEmail, '', ''],
      [fixtureEmail, 'a1', 'a1'],
      [fixtureEmail, 'abcdef', 'abcdef'],
      [fixtureEmail, 'ABC123', 'ABC123'],
      [fixtureEmail, fixturePassword, 'different'],
    ]) {
      expect(await auth.signUp(input[0], input[1], input[2]), isFalse);
      expect(auth.error, isNotNull);
      expect(auth.isLoading, isFalse);
      expect(auth.isAuthenticated, isFalse);
    }
    expect(requests, isEmpty);
  });

  test(
      'signup confirmation sends only email/password and no session grants access',
      () async {
    handler = (_) async => jsonResponse(fixtureUser);
    expect(
        await auth.signUp(' $fixtureEmail ', fixturePassword, fixturePassword),
        isTrue);
    expect(auth.isAuthenticated, isFalse);
    expect(auth.user, isNull);
    expect(auth.message, contains('confirmação'));
    expect(requests.single.url.path, '/auth/v1/signup');
    final payload = jsonDecode(requests.single.body) as Map;
    expect(payload['email'], fixtureEmail);
    expect(payload['password'], fixturePassword);
    expect(payload.containsKey('passwordConfirm'), isFalse);
    expect(requests.single.url.queryParameters['redirect_to'],
        'https://soufeeacao.pages.dev');
  });

  test('signup with a returned session authenticates', () async {
    expect(await auth.signUp(fixtureEmail, fixturePassword, fixturePassword),
        isTrue);
    expect(auth.isAuthenticated, isTrue);
    expect(auth.message, isNull);
  });

  test('sign in and logout use Supabase Auth and clear access', () async {
    expect(await auth.signIn(fixtureEmail, fixturePassword), isTrue);
    expect(auth.isAuthenticated, isTrue);
    expect(requests.single.url.path, '/auth/v1/token');
    handler = (_) async => http.Response('', 204);
    await auth.signOut();
    expect(requests.last.url.path, '/auth/v1/logout');
    expect(auth.isAuthenticated, isFalse);
    expect(auth.isLoading, isFalse);
    expect(auth.error, isNull);
  });

  test('initial provider observes an existing SDK session', () async {
    await client.auth
        .signInWithPassword(email: fixtureEmail, password: fixturePassword);
    final restored = AuthProvider(client: client);
    expect(restored.isAuthenticated, isTrue);
    restored.dispose();
  });

  test('empty or malformed login is blocked before HTTP', () async {
    expect(await auth.signIn('', fixturePassword), isFalse);
    expect(await auth.signIn('invalid', fixturePassword), isFalse);
    expect(await auth.signIn(fixtureEmail, ''), isFalse);
    expect(requests, isEmpty);
  });

  test('backend error details are not shown in signup or login', () async {
    handler = (_) async => jsonResponse(
        {'msg': 'private-backend-detail-fixture', 'code': 400}, 400);
    expect(await auth.signUp(fixtureEmail, fixturePassword, fixturePassword),
        isFalse);
    expect(auth.error, isNot(contains('private-backend-detail-fixture')));
    expect(await auth.signIn(fixtureEmail, fixturePassword), isFalse);
    expect(auth.error, isNot(contains('private-backend-detail-fixture')));
    expect(auth.isLoading, isFalse);
  });

  test('network failure produces recoverable feedback', () async {
    handler =
        (_) async => throw http.ClientException('private-network-fixture');
    expect(await auth.signIn(fixtureEmail, fixturePassword), isFalse);
    expect(auth.error, isNot(contains('private-network-fixture')));
    expect(auth.isLoading, isFalse);
  });

  test('logout failure is visible and permits retry', () async {
    await auth.signIn(fixtureEmail, fixturePassword);
    handler = (_) async => jsonResponse({'msg': 'test failure'}, 500);
    await auth.signOut();
    expect(auth.error, contains('Não foi possível sair'));
    expect(auth.isLoading, isFalse);
  });

  test('double submission does not create duplicate requests', () async {
    final pending = Completer<http.Response>();
    handler = (_) => pending.future;
    final first = auth.signIn(fixtureEmail, fixturePassword);
    expect(auth.isLoading, isTrue);
    expect(await auth.signIn(fixtureEmail, fixturePassword), isFalse);
    pending.complete(jsonResponse(fixtureSession()));
    expect(await first, isTrue);
    expect(requests, hasLength(1));
  });
}
