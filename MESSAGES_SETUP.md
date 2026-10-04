# Módulo Mensagens

O módulo abre em **Mais → Mensagens** e também em `/mensagens` ou
`/mensagens/<slug>`. Visitantes podem ler, buscar, copiar, compartilhar, baixar
uma arte 1080 × 1080 e guardar favoritos no dispositivo. A cópia inclui a
referência e o link da mensagem. No Web, o compartilhamento de texto volta para
cópia quando a API nativa não está disponível.

O catálogo inicial usa 12 versículos da Bíblia Livre já incorporados ao piloto,
com a atribuição exibida na lista e no detalhe. Quatro fundos de gradiente são
desenhados pelo próprio aplicativo; nenhuma imagem do site de referência foi
copiada. As mensagens remotas publicadas são lidas do Supabase, com o catálogo
local disponível quando a conexão falha.

Para ativar o catálogo remoto e os favoritos de usuários conectados, aplique
manualmente [a migration](supabase/migrations/20261003000100_messages.sql) no
projeto Supabase correto, após revisão. Ela cria `messages` e
`message_favorites`, insere as mesmas 12 mensagens e habilita RLS. Visitantes e
usuários conectados só podem ler mensagens publicadas; cada usuário conectado
só pode ler, adicionar e excluir seus próprios favoritos. Publicação e edição
ficam reservadas ao ambiente administrativo confiável; não existe chave de
serviço no aplicativo.

O build usa as variáveis públicas `SUPABASE_URL` e `SUPABASE_ANON_KEY` já
documentadas no README. Sem elas, a experiência visitante funciona com o
catálogo local. `web/_redirects` permite abrir os caminhos diretamente no
Cloudflare Pages; `vercel.json` contém regras equivalentes para Vercel. Em
outros hosts, configure a reescrita de `/mensagens` e `/mensagens/*` para
`/index.html`.

Não foi criado rastreamento de cópias, downloads ou compartilhamentos. O PNG
é gerado localmente por `RepaintBoundary`; no navegador, o arquivo é baixado,
e em plataformas sem download direto ele é oferecido via compartilhamento.
