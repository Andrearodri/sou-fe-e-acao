# Guia de Deployment - Vida com Cristo

## 1. Configuração Local

### Pré-requisitos
- Flutter SDK (versão 3.0+)
- Dart SDK
- Git
- Conta Supabase

### Setup Inicial

```bash
# Clone o repositório
git clone https://github.com/Andrearodri/vida-com-cristo.git
cd vida-com-cristo

# Instale dependências
flutter pub get

# Configure o Supabase
# 1. Abra lib/config/supabase_config.dart
# 2. Substitua YOUR_SUPABASE_URL e YOUR_SUPABASE_ANON_KEY
# 3. Obtenha estas chaves em https://app.supabase.com
```

## 2. Deploy PWA (Web)

### Build para Web

```bash
flutter build web --release
```

### Deploy no Vercel

1. Instale Vercel CLI: `npm i -g vercel`
2. Configure `vercel.json` na raiz do projeto
3. Execute: `vercel --prod`

### Deploy no Netlify

1. Instale Netlify CLI: `npm i -g netlify-cli`
2. Execute: `netlify deploy --prod --dir=build/web`

## 3. Deploy Mobile

### Android (Google Play Store)

1. Crie um keystore:
   ```bash
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vida-com-cristo
   ```

2. Build APK:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

3. Upload em: https://play.google.com/console

### iOS (App Store)

1. Configure certificados em https://developer.apple.com
2. Build:
   ```bash
   flutter build ipa --release
   ```
3. Upload usando Xcode ou Transporter

## 4. CI/CD com GitHub Actions

Crie `.github/workflows/deploy.yml` para automatizar builds e deploys.

## 5. Estrutura de Banco de Dados (Supabase)

### Tabela: users
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE,
  created_at TIMESTAMP
);
```

### Tabela: devocionais
```sql
CREATE TABLE devocionais (
  id UUID PRIMARY KEY,
  titulo TEXT,
  conteudo TEXT,
  data DATE,
  created_at TIMESTAMP
);
```

### Tabela: oracoes
```sql
CREATE TABLE oracoes (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  titulo TEXT,
  descricao TEXT,
  created_at TIMESTAMP
);
```

### Tabela: comunidade
```sql
CREATE TABLE comunidade (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  mensagem TEXT,
  created_at TIMESTAMP
);
```

## 6. URLs de Deploy

- **Web (PWA)**: https://vida-com-cristo.vercel.app
- **Android**: Google Play Store
- **iOS**: App Store

## 7. Checklist Final

- [ ] Supabase configurado
- [ ] Variáveis de ambiente definidas
- [ ] Build web testado localmente
- [ ] Build APK testado
- [ ] CI/CD configurado
- [ ] Dominio custom configurado (opcional)
- [ ] SSL ativado
- [ ] Analytics configurado
