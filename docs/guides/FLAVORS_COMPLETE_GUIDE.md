# WeGig - Guia Completo de Flavors

Configuração de 3 ambientes (flavors) para desenvolvimento, staging e produção.

## 📋 Índice

- [Arquitetura de Flavors](#arquitetura-de-flavors)
- [Configuração Firebase](#configuração-firebase)
- [Executar App por Flavor](#executar-app-por-flavor)
- [Build Release com Obfuscação](#build-release-com-obfuscação)
- [iOS Configuration](#ios-configuration)
- [Troubleshooting](#troubleshooting)

---

## 🏗️ Arquitetura de Flavors

### Flavors Disponíveis

| Flavor      | Ambiente    | Firebase Project     | Bundle ID                    | Debug Banner | Logs   | Crashlytics |
| ----------- | ----------- | -------------------- | ---------------------------- | ------------ | ------ | ----------- |
| **dev**     | Development | to-sem-banda-dev     | com.tosembanda.wegig.dev     | ✅ Sim       | ✅ Sim | ❌ Não      |
| **staging** | Staging/QA  | to-sem-banda-staging | com.tosembanda.wegig.staging | ✅ Sim       | ✅ Sim | ✅ Sim      |
| **prod**    | Production  | to-sem-banda-83e19   | com.tosembanda.wegig         | ❌ Não       | ❌ Não | ✅ Sim      |

### Estrutura de Arquivos

```
packages/app/lib/
├── main.dart                    # Main padrão (usa flavor prod)
├── main_dev.dart                # Entry point DEV
├── main_staging.dart            # Entry point STAGING
├── main_prod.dart               # Entry point PRODUCTION
├── firebase_options.dart        # Firebase PROD (padrão)
├── firebase_options_dev.dart    # Firebase DEV
├── firebase_options_staging.dart # Firebase STAGING
├── firebase_options_prod.dart   # Firebase PROD (explícito)
└── config/
    ├── app_config.dart          # Configuração centralizada
    ├── dev_config.dart          # Constantes DEV
    ├── staging_config.dart      # Constantes STAGING
    └── prod_config.dart         # Constantes PROD
```

### Como Funciona

1. **Entry Point**: Cada flavor tem seu próprio `main_*.dart`
2. **Firebase Options**: Cada flavor carrega configuração Firebase específica
3. **App Config**: Constantes e feature flags por ambiente
4. **Android Flavors**: Configurado em `android/app/build.gradle.kts`
5. **iOS Schemes**: Configurado no Xcode (ver seção iOS)

---

## 🔥 Configuração Firebase

### 1. Criar Projetos Firebase

Você precisa de **3 projetos Firebase** (ou pode usar 1 para dev/staging):

1. **DEV**: `to-sem-banda-dev`
2. **STAGING**: `to-sem-banda-staging`
3. **PROD**: `to-sem-banda-83e19` (já existe)

### 2. Adicionar Apps aos Projetos

Para cada projeto Firebase, adicione 2 apps (Android + iOS):

#### Android

- **DEV**: `com.tosembanda.wegig.dev`
- **STAGING**: `com.tosembanda.wegig.staging`
- **PROD**: `com.tosembanda.wegig`

#### iOS

- **DEV**: `com.tosembanda.wegig.dev`
- **STAGING**: `com.tosembanda.wegig.staging`
- **PROD**: `com.tosembanda.wegig`

### 3. Gerar Configurações com FlutterFire CLI

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# DEV
flutterfire configure \
  --project=to-sem-banda-dev \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.tosembanda.wegig.dev \
  --android-package-name=com.tosembanda.wegig.dev

# STAGING
flutterfire configure \
  --project=to-sem-banda-staging \
  --out=lib/firebase_options_staging.dart \
  --ios-bundle-id=com.tosembanda.wegig.staging \
  --android-package-name=com.tosembanda.wegig.staging

# PROD
flutterfire configure \
  --project=to-sem-banda-83e19 \
  --out=lib/firebase_options_prod.dart \
  --ios-bundle-id=com.tosembanda.wegig \
  --android-package-name=com.tosembanda.wegig
```

### 4. Configurar google-services.json (Android)

Baixe os arquivos `google-services.json` de cada projeto Firebase:

```
android/app/src/
├── dev/google-services.json        # Firebase DEV
├── staging/google-services.json    # Firebase STAGING
└── prod/google-services.json       # Firebase PROD (ou na raiz android/app/)
```

### 5. Configurar GoogleService-Info.plist (iOS)

No Xcode, adicione os arquivos `.plist` para cada scheme (ver seção iOS).

---

## 🚀 Executar App por Flavor

### Android

```bash
# DEV (desenvolvimento local)
cd packages/app
flutter run --flavor dev --target lib/main_dev.dart

# STAGING (testes internos)
flutter run --flavor staging --target lib/main_staging.dart

# PROD (produção)
flutter run --flavor prod --target lib/main_prod.dart
```

### iOS

```bash
# DEV
flutter run --flavor dev --target lib/main_dev.dart

# STAGING
flutter run --flavor staging --target lib/main_staging.dart

# PROD
flutter run --flavor prod --target lib/main_prod.dart
```

### VS Code Launch Configuration

Crie `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "WeGig DEV",
      "request": "launch",
      "type": "dart",
      "program": "packages/app/lib/main_dev.dart",
      "args": ["--flavor", "dev", "--dart-define=FLAVOR=dev"]
    },
    {
      "name": "WeGig STAGING",
      "request": "launch",
      "type": "dart",
      "program": "packages/app/lib/main_staging.dart",
      "args": ["--flavor", "staging", "--dart-define=FLAVOR=staging"]
    },
    {
      "name": "WeGig PROD",
      "request": "launch",
      "type": "dart",
      "program": "packages/app/lib/main_prod.dart",
      "args": ["--flavor", "prod", "--dart-define=FLAVOR=prod"]
    }
  ]
}
```

---

## 📦 Build Release com Obfuscação

### Script Automatizado

Use o script `build_release.sh` para builds otimizados:

```bash
# DEV - APK para testes internos
./scripts/build_release.sh dev android

# STAGING - AAB para teste em produção
./scripts/build_release.sh staging android

# PROD - AAB otimizado para Play Store
./scripts/build_release.sh prod android

# iOS
./scripts/build_release.sh prod ios
```

### Proteções Aplicadas

✅ **Code Obfuscation** (`--obfuscate`)

- Ofusca nomes de classes, métodos e variáveis
- Dificulta engenharia reversa
- Reduz tamanho do binário em ~10-15%

✅ **Split Debug Info** (`--split-debug-info`)

- Separa símbolos de debug do APK/IPA
- Necessário para desobfuscar crash reports
- **IMPORTANTE**: Guarde os símbolos em local seguro!

✅ **ProGuard** (Android)

- Minificação de código
- Remoção de código não utilizado
- Otimização de bytecode

✅ **Resource Shrinking** (Android)

- Remove recursos não utilizados (imagens, strings)
- Reduz tamanho do APK em 5-10%

### Símbolos de Debug

Os símbolos são salvos em:

```
build/symbols/
├── dev/
│   ├── android/
│   └── ios/
├── staging/
│   ├── android/
│   └── ios/
└── prod/
    ├── android/
    └── ios/
```

**⚠️ CRÍTICO**:

- **NUNCA** faça commit dos símbolos no Git
- Guarde em local seguro (backup criptografado)
- Upload para Firebase Crashlytics após cada deploy:

```bash
firebase crashlytics:symbols:upload \
  --app=<firebase-app-id> \
  build/symbols/prod/android/
```

### Build Manual (sem script)

```bash
# Android APK
cd packages/app
flutter build apk \
  --release \
  --flavor prod \
  --target lib/main_prod.dart \
  --obfuscate \
  --split-debug-info=build/symbols/prod/android \
  --dart-define=FLAVOR=prod

# Android AAB (App Bundle)
flutter build appbundle \
  --release \
  --flavor prod \
  --target lib/main_prod.dart \
  --obfuscate \
  --split-debug-info=build/symbols/prod/android-bundle \
  --dart-define=FLAVOR=prod

# iOS
flutter build ios \
  --release \
  --flavor prod \
  --target lib/main_prod.dart \
  --obfuscate \
  --split-debug-info=build/symbols/prod/ios \
  --dart-define=FLAVOR=prod
```

---

## 🍎 iOS Configuration

### 1. Abrir Xcode

```bash
cd packages/app/ios
open Runner.xcworkspace
```

### 2. Criar Schemes (se não existirem)

1. **Product → Scheme → Manage Schemes**
2. Clicar em **+** para adicionar novo scheme
3. Criar 3 schemes:
   - `dev` (based on Runner)
   - `staging` (based on Runner)
   - `prod` (based on Runner)

### 3. Configurar Build Configurations

1. Selecionar **Runner** no Project Navigator
2. **Info** tab → Configurations
3. Duplicar **Release**:
   - `Release-dev`
   - `Release-staging`
   - `Release-prod`

### 4. Configurar GoogleService-Info.plist por Scheme

Para cada scheme:

1. **Product → Scheme → Edit Scheme**
2. **Build → Pre-actions**
3. Adicionar **Run Script**:

```bash
# Script para copiar GoogleService-Info.plist correto
FLAVOR="${CONFIGURATION##*-}" # Extrai dev/staging/prod do nome da configuration

if [ "$FLAVOR" == "dev" ]; then
    cp "${PROJECT_DIR}/Firebase/GoogleService-Info-dev.plist" "${PROJECT_DIR}/Runner/GoogleService-Info.plist"
elif [ "$FLAVOR" == "staging" ]; then
    cp "${PROJECT_DIR}/Firebase/GoogleService-Info-staging.plist" "${PROJECT_DIR}/Runner/GoogleService-Info.plist"
else
    cp "${PROJECT_DIR}/Firebase/GoogleService-Info-prod.plist" "${PROJECT_DIR}/Runner/GoogleService-Info.plist"
fi
```

### 5. Organizar arquivos .plist

```
ios/
├── Firebase/
│   ├── GoogleService-Info-dev.plist
│   ├── GoogleService-Info-staging.plist
│   └── GoogleService-Info-prod.plist
└── Runner/
    └── GoogleService-Info.plist  # Copiado em tempo de build
```

### 6. Configurar Bundle ID por Flavor

1. Selecionar **Runner** target
2. **Build Settings** → **Product Bundle Identifier**
3. Expandir e configurar por configuration:
   - `Release-dev`: `com.tosembanda.wegig.dev`
   - `Release-staging`: `com.tosembanda.wegig.staging`
   - `Release-prod`: `com.tosembanda.wegig`

### 7. Configurar Display Name

**Build Settings** → **Product Name**:

- `Release-dev`: `WeGig DEV`
- `Release-staging`: `WeGig STAGING`
- `Release-prod`: `WeGig`

---

## 🔧 Troubleshooting

### Erro: "No Firebase App '[DEFAULT]' has been created"

**Causa**: Firebase não inicializado corretamente

**Solução**:

1. Verificar se `google-services.json` (Android) ou `.plist` (iOS) existe
2. Executar `flutter clean` e rebuild
3. Confirmar que `Firebase.initializeApp()` é chamado antes de qualquer código Firebase

### Erro: "MISSING_INSTANCEID_SERVICE"

**Causa**: Configuração FCM (Firebase Cloud Messaging) incorreta

**Solução**:

1. Recriar app no Firebase Console
2. Baixar novo `google-services.json` / `.plist`
3. Habilitar Cloud Messaging API no Google Cloud Console

### Erro: "Duplicate class found" (Android)

**Causa**: Conflito de dependências Firebase

**Solução**:

```bash
cd packages/app/android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### App Crasha ao Abrir (Release Build)

**Causa**: Obfuscação quebrou reflexão

**Solução**: Adicionar regras ProGuard em `android/app/proguard-rules.pro`:

```proguard
# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Riverpod
-keep class * extends com.riverpod.** { *; }

# Model classes (substitua com seus modelos)
-keep class com.tosembanda.wegig.models.** { *; }
```

### Debug Symbols Não Uploadam para Crashlytics

**Causa**: Símbolos não foram gerados ou path incorreto

**Solução**:

1. Verificar se pasta `build/symbols/` existe
2. Confirmar que build foi feito com `--obfuscate --split-debug-info`
3. Upload manual:

```bash
firebase crashlytics:symbols:upload \
  --app=1:YOUR_APP_ID:android:YOUR_ANDROID_ID \
  build/symbols/prod/android/
```

### Flavor Errado Aparece no Device

**Causa**: Cache de build anterior

**Solução**:

```bash
# Android
adb uninstall com.tosembanda.wegig.dev
adb uninstall com.tosembanda.wegig.staging
adb uninstall com.tosembanda.wegig

# iOS
flutter clean
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

---

## 📚 Recursos Adicionais

- [Flutter Flavors Official Docs](https://flutter.dev/docs/deployment/flavors)
- [Firebase Multi-Environment Setup](https://firebase.google.com/docs/projects/multiprojects)
- [ProGuard Rules](https://developer.android.com/studio/build/shrink-code#keep-code)
- [Code Obfuscation Best Practices](https://flutter.dev/docs/deployment/obfuscate)

---

## ✅ Checklist de Deploy

- [ ] Criar 3 projetos Firebase (dev, staging, prod)
- [ ] Adicionar apps Android/iOS em cada projeto
- [ ] Gerar `firebase_options_*.dart` com FlutterFire CLI
- [ ] Baixar `google-services.json` para Android
- [ ] Baixar `GoogleService-Info.plist` para iOS
- [ ] Configurar schemes no Xcode (iOS)
- [ ] Testar build de cada flavor em debug
- [ ] Testar build release com obfuscação
- [ ] Guardar símbolos de debug em backup
- [ ] Upload símbolos para Crashlytics
- [ ] Testar app em device físico
- [ ] Deploy para TestFlight (iOS) / Internal Testing (Android)
- [ ] Monitorar crash reports por 24h antes de produção

---

**Última atualização**: 29 de Novembro de 2025  
**Versão**: 1.0.0  
**Autor**: ToSemBanda Team
