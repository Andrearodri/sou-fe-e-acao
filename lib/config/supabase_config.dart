import 'dart:convert';

class SupabaseConfig {
  const SupabaseConfig({
    this.url = const String.fromEnvironment('SUPABASE_URL'),
    this.anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY'),
  });

  final String url;
  final String anonKey;

  /// Returns messages containing variable names, never their values.
  String? get validationError {
    if (url.trim().isEmpty || anonKey.trim().isEmpty) {
      return 'Configure SUPABASE_URL e SUPABASE_ANON_KEY com --dart-define '
          'antes de iniciar o aplicativo.';
    }
    final uri = Uri.tryParse(url);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      return 'SUPABASE_URL deve ser uma URL HTTPS válida do projeto Supabase.';
    }
    if (anonKey.startsWith('sb_secret_')) {
      return 'Use somente uma chave pública anon em SUPABASE_ANON_KEY. '
          'Chaves secret/service_role não podem ser usadas no frontend.';
    }
    final parts = anonKey.split('.');
    if (parts.length != 3) {
      return 'SUPABASE_ANON_KEY deve ser a chave pública anon JWT do projeto.';
    }
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map || payload['role'] != 'anon') {
        return 'SUPABASE_ANON_KEY deve ter papel anon; '
            'service_role não pode ser usado no frontend.';
      }
    } on FormatException {
      return 'SUPABASE_ANON_KEY deve ser a chave pública anon JWT do projeto.';
    }
    return null;
  }
}
