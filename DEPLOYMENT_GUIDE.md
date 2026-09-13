# Notas de deploy

O aplicativo Flutter Web está publicado no Cloudflare Pages em
<https://soufeeacao.com.br>. Este documento é apenas uma referência curta; os
comandos seguros de execução e build estão no [README](README.md).

O build configurado recebe `SUPABASE_URL` e `SUPABASE_ANON_KEY` apenas via
`--dart-define`. Não registre valores reais em arquivos, histórico Git ou logs.
O MVP usa Supabase somente para Auth; não há tabelas, migrations, Storage ou
funções server-side para implantar.
