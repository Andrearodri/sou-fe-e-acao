import 'package:flutter_test/flutter_test.dart';
import 'package:vida_com_cristo/config/supabase_config.dart';

import 'support/auth_fixture.dart';

void main() {
  test('missing configuration identifies variables without values', () {
    const config = SupabaseConfig(url: '', anonKey: '');
    expect(config.validationError, contains('SUPABASE_URL'));
    expect(config.validationError, contains('SUPABASE_ANON_KEY'));
  });

  test('accepts HTTPS and a synthetic anon JWT', () {
    expect(
      SupabaseConfig(
              url: 'https://example.invalid', anonKey: fixtureJwt('anon'))
          .validationError,
      isNull,
    );
  });

  test('rejects HTTP, embedded credentials and query parameters', () {
    for (final url in [
      'http://example.invalid',
      'https://fixture:fixture@example.invalid',
      'https://example.invalid?test=value',
      'not-a-url',
    ]) {
      final error =
          SupabaseConfig(url: url, anonKey: fixtureJwt('anon')).validationError;
      expect(error, isNotNull);
      expect(error, isNot(contains(url)));
    }
  });

  test('rejects service_role and secret keys without echoing them', () {
    for (final key in [fixtureJwt('service_role'), 'sb_secret_test-only']) {
      final error = SupabaseConfig(url: 'https://example.invalid', anonKey: key)
          .validationError;
      expect(error, isNotNull);
      expect(error, isNot(contains(key)));
    }
  });

  test('malformed anon configuration fails clearly', () {
    for (final key in ['placeholder', 'a.%%%.b', 'a.bnVsbA.b']) {
      expect(
        SupabaseConfig(url: 'https://example.invalid', anonKey: key)
            .validationError,
        isNotNull,
      );
    }
  });
}
