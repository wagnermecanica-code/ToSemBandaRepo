# 🔥 Guia: Criar Projetos Firebase Separados (DEV/STAGING)

**Objetivo**: Isolar ambientes de desenvolvimento, homologação e produção com projetos Firebase independentes.

**Tempo estimado**: 30-45 minutos  
**Pré-requisitos**: Conta Google, acesso ao Firebase Console

---

## 📋 Visão Geral

### Por que Projetos Separados?

| Aspecto       | Projeto Único ❌                  | Projetos Separados ✅                        |
| ------------- | --------------------------------- | -------------------------------------------- |
| **Dados**     | Compartilhados (risco de mistura) | Isolados por ambiente                        |
| **Custos**    | Difícil rastrear por ambiente     | Faturamento separado por projeto             |
| **Regras**    | Mesmas regras para todos          | Regras específicas (ex: dev mais permissiva) |
| **Segurança** | Dados de teste em produção        | Teste com dados falsos isolados              |
| **Analytics** | Métricas misturadas               | Métricas limpas por ambiente                 |

### Estrutura Atual vs. Ideal

**ATUAL** (1 projeto):

```
to-sem-banda-83e19 (PROD)
├── com.tosembanda.wegig
├── com.tosembanda.wegig.dev      ← Compartilha dados PROD!
└── com.tosembanda.wegig.staging  ← Compartilha dados PROD!
```

**IDEAL** (3 projetos):

```
to-sem-banda-dev
└── com.tosembanda.wegig.dev      ← Dados isolados

to-sem-banda-staging
└── com.tosembanda.wegig.staging  ← Dados isolados

to-sem-banda-83e19 (PROD)
└── com.tosembanda.wegig          ← Dados reais, seguros
```

---

## 🚀 Parte 1: Criar Projetos no Firebase Console

### Passo 1.1: Criar Projeto DEV

1. **Abra**: https://console.firebase.google.com/
2. Clique em **"Add project"** ou **"Adicionar projeto"**
3. Preencha:
   - **Nome do projeto**: `WeGig DEV`
   - **Project ID**: Deixe gerar automaticamente ou use `to-sem-banda-dev`
   - Clique **"Continue"**
4. **Google Analytics**: Desabilitar (opcional - recomendado para dev)
   - Toggle OFF: "Enable Google Analytics"
   - Clique **"Create project"**
5. Aguarde 30-60 segundos
6. Clique **"Continue"** quando pronto

### Passo 1.2: Criar Projeto STAGING

Repita os passos acima com:

- **Nome**: `WeGig STAGING`
- **Project ID**: `to-sem-banda-staging` (ou gerado)

### Passo 1.3: Anotar Project IDs

Anote os Project IDs criados:

```
✅ DEV:     wegig-dev (Project number: 963929089370)
✅ STAGING: wegig-staging (Project number: 27906769066)
✅ PROD:    to-sem-banda-83e19 (existente)
```

**Apps Registrados:**

**DEV** (wegig-dev):

- Android: `1:963929089370:android:1a6d15efd0ca5ecfec7f63`
- iOS: `1:963929089370:ios:09b43a150f6d7ec1ec7f63`

**STAGING** (wegig-staging):

- Android: `1:27906769066:android:1dfb4c1cff7bbfbdbcd0d3`
- iOS: `1:27906769066:ios:e18b9605552d60e5bcd0d3`

---

## 🔧 Parte 2: Configurar Apps com FlutterFire CLI

### Opção A: Script Automatizado (Recomendado)

```bash
# Execute o script interativo
./scripts/setup_firebase_projects.sh
```

O script vai:

1. ✅ Verificar instalações (Firebase CLI, FlutterFire CLI)
2. ✅ Configurar DEV e STAGING automaticamente
3. ✅ Registrar apps Android/iOS em cada projeto
4. ✅ Gerar `firebase_options_*.dart`
5. ⏳ Guiar downloads manuais (google-services.json, plist)

### Opção B: Configuração Manual

Se preferir fazer manualmente:

#### 2.1: Instalar FlutterFire CLI (se ainda não tiver)

```bash
dart pub global activate flutterfire_cli
```

#### 2.2: Configurar DEV

```bash
cd packages/app

flutterfire configure \
  --project=to-sem-banda-dev \
  --out=lib/firebase_options_dev.dart \
  --platforms=android,ios \
  --ios-bundle-id=com.tosembanda.wegig.dev \
  --android-package-name=com.tosembanda.wegig.dev \
  --yes
```

**Resultado esperado**:

```
✔ Firebase android app com.tosembanda.wegig.dev registered
✔ Firebase ios app com.tosembanda.wegig.dev registered
✔ Firebase configuration file lib/firebase_options_dev.dart generated
```

#### 2.3: Configurar STAGING

```bash
flutterfire configure \
  --project=to-sem-banda-staging \
  --out=lib/firebase_options_staging.dart \
  --platforms=android,ios \
  --ios-bundle-id=com.tosembanda.wegig.staging \
  --android-package-name=com.tosembanda.wegig.staging \
  --yes
```

---

## 📥 Parte 3: Baixar Arquivos de Configuração

### 3.1: Google Services (Android)

Para **CADA projeto** (DEV e STAGING):

1. Abra o projeto no Firebase Console
2. **Project Overview** → **⚙️ Project Settings**
3. Scroll até **"Your apps"**
4. Encontre o app **Android** (`com.tosembanda.wegig.dev`)
5. Clique em **"google-services.json"** para baixar
6. Salve em:
   - DEV: `packages/app/android/app/src/dev/google-services.json`
   - STAGING: `packages/app/android/app/src/staging/google-services.json`

**Verificação**:

```bash
cd packages/app/android/app
ls -la src/dev/google-services.json      # Deve existir
ls -la src/staging/google-services.json  # Deve existir
```

### 3.2: GoogleService-Info.plist (iOS)

Para **CADA projeto** (DEV e STAGING):

1. Mesma tela de Project Settings
2. Encontre o app **iOS** (`com.tosembanda.wegig.dev`)
3. Clique em **"GoogleService-Info.plist"** para baixar
4. Salve em:
   - DEV: `packages/app/ios/Firebase/GoogleService-Info-dev.plist`
   - STAGING: `packages/app/ios/Firebase/GoogleService-Info-staging.plist`

**Verificação**:

```bash
cd packages/app/ios/Firebase
ls -la GoogleService-Info-dev.plist      # Deve existir
ls -la GoogleService-Info-staging.plist  # Deve existir
```

---

## 🔐 Parte 4: Habilitar Serviços Firebase

Para **CADA projeto** (DEV e STAGING), habilite:

### 4.1: Authentication

1. **Build** → **Authentication** → **Get Started**
2. **Sign-in method** → Habilitar:
   - ✅ **Email/Password**
   - ✅ **Google** (configure OAuth consent screen)
   - ✅ **Apple** (configure Service ID no Apple Developer)

### 4.2: Firestore Database

1. **Build** → **Firestore Database** → **Create database**
2. **Location**: `southamerica-east1` (São Paulo)
3. **Security rules**: Start in **test mode** (DEV) ou **production mode** (STAGING)
4. Clique **"Enable"**

### 4.3: Storage

1. **Build** → **Storage** → **Get started**
2. **Security rules**: Start in **test mode** (DEV) ou **production mode** (STAGING)
3. Clique **"Done"**

### 4.4: Cloud Messaging (FCM)

1. **Project Settings** → **Cloud Messaging**
2. Copie **Server Key** e **Sender ID** (para referência)

### 4.5: Crashlytics

1. **Release & Monitor** → **Crashlytics** → **Get started**
2. Siga as instruções (já configurado no app)

---

## 📜 Parte 5: Configurar Firestore Rules e Indexes

### 5.1: Deploy Rules para DEV

```bash
cd /Users/wagneroliveira/to_sem_banda

# Selecionar projeto DEV
firebase use to-sem-banda-dev

# Deploy indexes (aguardar 2-5 minutos para "Enabled")
firebase deploy --only firestore:indexes

# Deploy rules
firebase deploy --only firestore:rules
```

### 5.2: Deploy Rules para STAGING

```bash
# Selecionar projeto STAGING
firebase use to-sem-banda-staging

# Deploy indexes
firebase deploy --only firestore:indexes

# Deploy rules
firebase deploy --only firestore:rules
```

### 5.3: Ajustar Rules para DEV (Opcional)

Para facilitar testes em DEV, você pode usar rules mais permissivas:

**DEV** (`firestore.rules` temporário):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // DEV: Permitir leitura/escrita autenticada (sem validações)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**STAGING/PROD**: Use as rules completas do `firestore.rules` atual

---

## 🧪 Parte 6: Testar Configuração

### 6.1: Limpar e Reinstalar

```bash
cd packages/app
flutter clean
flutter pub get
```

### 6.2: Testar Build DEV

```bash
flutter build apk --flavor dev -t lib/main_dev.dart --debug
```

**Resultado esperado**:

```
✓ Built build/app/outputs/flutter-apk/app-dev-debug.apk
```

### 6.3: Testar Build STAGING

```bash
flutter build apk --flavor staging -t lib/main_staging.dart --debug
```

### 6.4: Executar e Testar Funcionalidades

```bash
# DEV
flutter run --flavor dev -t lib/main_dev.dart

# STAGING
flutter run --flavor staging -t lib/main_staging.dart
```

**Teste**:

1. ✅ Login com email/senha
2. ✅ Criar perfil
3. ✅ Criar post
4. ✅ Upload de imagem
5. ✅ Chat funciona

---

## 📊 Parte 7: Configurar Dados de Teste (Opcional)

### 7.1: Popular DEV com Dados Falsos

```javascript
// Script Node.js: scripts/populate_dev_data.js
const admin = require("firebase-admin");

admin.initializeApp({
  projectId: "to-sem-banda-dev",
});

const db = admin.firestore();

async function populateData() {
  // Criar usuários de teste
  await db.collection("users").doc("test-user-1").set({
    email: "dev1@wegig.com",
    displayName: "Desenvolvedor 1",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Criar perfis de teste
  await db
    .collection("profiles")
    .doc("profile-1")
    .set({
      uid: "test-user-1",
      name: "João Guitarrista",
      isBand: false,
      instruments: ["Guitarra"],
      city: "São Paulo",
    });

  console.log("✅ Dados de teste criados");
}

populateData();
```

Execute:

```bash
cd scripts
npm install firebase-admin
GOOGLE_APPLICATION_CREDENTIALS=../service-account-dev.json node populate_dev_data.js
```

---

## ✅ Checklist Final

- [ ] ✅ Projeto DEV criado no Firebase Console
- [ ] ✅ Projeto STAGING criado no Firebase Console
- [ ] ✅ FlutterFire CLI configurou DEV (`firebase_options_dev.dart`)
- [ ] ✅ FlutterFire CLI configurou STAGING (`firebase_options_staging.dart`)
- [ ] ✅ `google-services.json` baixado para DEV
- [ ] ✅ `google-services.json` baixado para STAGING
- [ ] ✅ `GoogleService-Info.plist` baixado para DEV
- [ ] ✅ `GoogleService-Info.plist` baixado para STAGING
- [ ] ✅ Authentication habilitado (Email, Google, Apple)
- [ ] ✅ Firestore Database criado
- [ ] ✅ Storage habilitado
- [ ] ✅ Firestore rules deployadas (DEV e STAGING)
- [ ] ✅ Firestore indexes deployados (DEV e STAGING)
- [ ] ✅ Build DEV funciona
- [ ] ✅ Build STAGING funciona
- [ ] ✅ App DEV conecta ao Firebase DEV
- [ ] ✅ App STAGING conecta ao Firebase STAGING
- [ ] ✅ Funcionalidades básicas testadas

---

## 🎯 Resultado Final

Após concluir, você terá:

### Estrutura de Projetos

```
📱 DEV (to-sem-banda-dev)
   └── Dados de teste, rules permissivas

📱 STAGING (to-sem-banda-staging)
   └── Dados de homologação, rules prod

📱 PROD (to-sem-banda-83e19)
   └── Dados reais, rules prod
```

### Comandos por Ambiente

```bash
# Desenvolvimento (dados falsos, logs verbose)
flutter run --flavor dev -t lib/main_dev.dart

# Homologação (dados similares a prod, teste final)
flutter run --flavor staging -t lib/main_staging.dart

# Produção (dados reais, usuários reais)
flutter run --flavor prod -t lib/main_prod.dart
```

### Firebase CLI por Projeto

```bash
# Alternar entre projetos
firebase use to-sem-banda-dev       # DEV
firebase use to-sem-banda-staging   # STAGING
firebase use to-sem-banda-83e19     # PROD (padrão)

# Ver projeto ativo
firebase use

# Deploy
firebase deploy --only firestore
firebase deploy --only functions
```

---

## 🚨 Troubleshooting

### Erro: "Firebase app not registered"

**Causa**: App não encontrado no projeto Firebase  
**Solução**: Execute `flutterfire configure` novamente

### Erro: "google-services.json not found"

**Causa**: Arquivo não está no diretório correto  
**Solução**: Verifique path exato:

```bash
packages/app/android/app/src/dev/google-services.json
packages/app/android/app/src/staging/google-services.json
```

### Build funciona mas app crasha

**Causa**: Projeto Firebase errado configurado  
**Solução**:

1. Verifique `lib/firebase_options_dev.dart` tem `projectId` correto
2. Force rebuild: `flutter clean && flutter pub get`

### Firestore rules negam acesso

**Causa**: Rules de PROD copiadas para DEV  
**Solução**: Use rules mais permissivas em DEV (veja Parte 5.3)

---

## 📚 Referências

- [Firebase Multi-Project Setup](https://firebase.google.com/docs/projects/multiprojects)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- **Guia Local**: `FLAVORS_COMPLETE_GUIDE.md`
- **Status**: `FIREBASE_FLAVORS_STATUS.md`

---

**Tempo total estimado**: 30-45 minutos  
**Complexidade**: Intermediária  
**Benefícios**: 🔒 Isolamento de dados, 📊 Métricas limpas, 💰 Custos rastreáveis
