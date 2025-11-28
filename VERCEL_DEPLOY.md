# Deploy Vida com Cristo no Vercel em 3 Cliques!

🚀 **O projeto ja esta configurado e pronto para deploy!**

## Método 1: Um Clique (RECOMENDADO)

Clique no botão abaixo:

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/Andrearodri/vida-com-cristo)

## Método 2: Via Dashboard Vercel

### Passo 1: Ir para Vercel
1. Abra https://vercel.com
2. Clique em "Sign Up" ou "Log In"
3. Escolha "Continue with GitHub"

### Passo 2: Importar Repositório
1. Clique em "New Project"
2. Cole a URL: `https://github.com/Andrearodri/vida-com-cristo`
3. Clique em "Continue"

### Passo 3: Configurar
1. Framework: Selecione "Other"
2. Build Command: `flutter build web --release`
3. Output Directory: `build/web`
4. Clique em "Deploy"

## ✅ Pronto!

Sua URL será: `https://vida-com-cristo.vercel.app`

O Vercel vai:
- ✅ Fazer build automático
- ✅ Fazer deploy com SSL
- ✅ Gerar preview URLs
- ✅ Atualizar em cada push no GitHub

## 🔧 Variáveis de Ambiente (Opcional)

Se quiser integrar Supabase em produção:

1. Após fazer deploy, vá em Settings
2. Clique em "Environment Variables"
3. Adicione:
   - `SUPABASE_URL` = sua URL do Supabase
   - `SUPABASE_ANON_KEY` = sua chave anon

## 📊 Status

- Framework: Flutter
- Build Output: PWA Web
- Build Time: ~5 minutos
- Region: Global (Vercel CDN)

**Tudo pronto! 🎉**
