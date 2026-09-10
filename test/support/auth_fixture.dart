import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Synthetic fixtures only. No credential or personal account is used.
const fixtureEmail = 'reader@example.invalid';
const fixturePassword = 'test-only-password-123';
const fixtureUser = {
  'id': '00000000-0000-0000-0000-000000000001',
  'aud': 'authenticated',
  'role': 'authenticated',
  'email': fixtureEmail,
  'app_metadata': <String, dynamic>{},
  'user_metadata': <String, dynamic>{},
  'created_at': '2025-01-01T00:00:00Z',
};

String fixtureJwt(String role) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${encode({
        'role': role,
        'sub': fixtureUser['id'],
        'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
      })}.test-only-invalid-signature';
}

Map<String, dynamic> fixtureSession() => {
      'access_token': fixtureJwt('authenticated'),
      'token_type': 'bearer',
      'expires_in': 3600,
      'refresh_token': 'test-only-refresh-token',
      'user': fixtureUser,
    };

http.Response jsonResponse(Object value, [int status = 200]) => http.Response(
      jsonEncode(value),
      status,
      headers: {'content-type': 'application/json'},
    );

SupabaseClient fixtureClient(MockClientHandler handler) => SupabaseClient(
      'https://example.invalid',
      fixtureJwt('anon'),
      autoRefreshToken: false,
      httpClient: MockClient(handler),
    );
