# Validação local

Use Flutter 3.47.2 e as dependências fixadas em `pubspec.lock`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release
```

A suíte atual possui 41 testes e não usa contas, e-mails ou credenciais reais.
Ela valida o modo guest, a navegação, a persistência local, a Bíblia piloto, os
devocionais, as orações e os fluxos de Auth com fixtures sintéticas. O build sem
`--dart-define` também deve funcionar para o CI porque o conteúdo público não
depende de Supabase.

Para validar o Auth contra um projeto real, informe somente a URL e a chave anon
no comando por `--dart-define`; não as salve em arquivos rastreados.
