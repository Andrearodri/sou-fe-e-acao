# Validação do MVP

Use Flutter 3.47.2 e as dependências de `pubspec.lock`:

```bash
flutter pub get --enforce-lockfile
flutter analyze
flutter test
```

O aplicativo abre em modo visitante. A Home Hoje mostra a rotina e o progresso
semanal em memória; a mesma rotina não pode ser contabilizada duas vezes no dia.
As áreas Bíblia e Orações informam honestamente o que ainda está em preparação.

O formulário de cadastro inclui confirmação de senha. A senha exige no mínimo
seis caracteres, uma letra minúscula e um número. Dados inválidos são bloqueados
antes da requisição de cadastro.

Um usuário retornado sem sessão não libera acesso à home: a interface orienta
confirmar o e-mail. Login e logout dependem do Supabase Auth configurado.

A suíte usa HTTP simulado, incluindo falhas e respostas de confirmação pendente.
Ela não valida envio de e-mail real nem a configuração da conta Supabase.
O build e os passos de homologação manual estão no [README](README.md).
