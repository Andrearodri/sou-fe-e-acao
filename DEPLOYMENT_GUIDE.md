# Preparação para produção

O guia de implantação vigente está no [README](README.md#deploy-planejado-cloudflare-pages).

O projeto usa Flutter Web e Supabase Auth. Não há tabelas próprias, migrations
ou storage necessários para o MVP. Não execute o antigo SQL sugerido para
funcionalidades de conteúdo ainda não implementadas.

Antes do deploy, configure e homologue Supabase Auth, confirmação por e-mail
e URLs de redirecionamento. Gere novamente `build/web` com as definições do
projeto real; o build de validação usa valores fictícios.

Cloudflare Pages é a hospedagem planejada para `soufeeacao.com.br`.
Nenhum deploy ou alteração de DNS foi realizado nesta preparação.
