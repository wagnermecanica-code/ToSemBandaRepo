# 🚀 Guia de Setup - Flavors (Dev / Staging / Prod)

Este guia mostra como configurar e usar os 3 flavors do WeGig: **dev**, **staging** e **prod**.

---

## 📋 Pré-requisitos

- Flutter 3.9.2+
- Dart 3.5+
- Xcode 15+ (para iOS)
- Android Studio / VSCode
- Firebase CLI (`npm install -g firebase-tools`)

---

## 🎯 Passo 1: Instalar Dependências

```bash
cd /Users/wagneroliveira/to_sem_banda
flutter pub get
```

---

## 🎨 Passo 2: Gerar Estrutura de Flavors

Execute o **flutter_flavorizr** para criar automaticamente:

- Configurações Android (`android/app/src/{dev,staging,prod}/`)
- Configurações iOS (`ios/Flutter/{dev,staging,prod}.xcconfig`)
- Targets Flutter (`lib/main_{dev,staging,prod}.dart`)
- Ícones com badges para cada flavor

```bash
flutter pub run flutter_flavorizr
```

**O que será criado:**

```
android/app/src/
├── dev/
│   ├── AndroidManifest.xml
│   └── res/
├── staging/
│   ├── AndroidManifest.xml
│   └── res/
└── prod/
    ├── AndroidManifest.xml
    └── res/

ios/Flutter/
├── Dev.xcconfig
├── Staging.xcconfig
└── Prod.xcconfig

lib/
├── main_dev.dart
├── main_staging.dart
└── main_prod.dart
```

---

## 🔥 Passo 3: Configurar Firebase para Cada Flavor

### 3.1 Criar Projetos Firebase

Crie 3 projetos no [Firebase Console](https://console.firebase.google.com):

1. **to-sem-banda-dev** (Desenvolvimento)
2. **to-sem-banda-staging** (Homologação)
3. **to-sem-banda-83e19** (Produção - **já existe**)

### 3.2 Baixar Arquivos de Configuração

Para cada projeto, baixe:

**Android:** `google-services.json`

```bash
# Criar estrutura de pastas
mkdir -p android/app/src/dev
mkdir -p android/app/src/staging
mkdir -p android/app/src/prod

# Copiar arquivos (baixados do Firebase Console)
# android/app/src/dev/google-services.json (to-sem-banda-dev)
# android/app/src/staging/google-services.json (to-sem-banda-staging)
# android/app/src/prod/google-services.json (to-sem-banda-83e19)
```

**iOS:** `GoogleService-Info.plist`

```bash
# Criar estrutura de pastas
mkdir -p ios/Firebase/dev
mkdir -p ios/Firebase/staging
mkdir -p ios/Firebase/prod

# Copiar arquivos (baixados do Firebase Console)
# ios/Firebase/dev/GoogleService-Info.plist (to-sem-banda-dev)
# ios/Firebase/staging/GoogleService-Info.plist (to-sem-banda-staging)
# ios/Firebase/prod/GoogleService-Info.plist (to-sem-banda-83e19)
```

### 3.3 Gerar `firebase_options.dart` por Flavor

```bash
# DEV
flutterfire configure \
  --project=to-sem-banda-dev \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.tosembanda.wegig.dev \
  --android-app-id=com.tosembanda.wegig.dev

# STAGING
flutterfire configure \
  --project=to-sem-banda-staging \
  --out=lib/firebase_options_staging.dart \
  --ios-bundle-id=com.tosembanda.wegig.staging \
  --android-app-id=com.tosembanda.wegig.staging

# PROD (já existe - to-sem-banda-83e19)
flutterfire configure \
  --project=to-sem-banda-83e19 \
  --out=lib/firebase_options_prod.dart \
  --ios-bundle-id=com.tosembanda.wegig \
  --android-app-id=com.tosembanda.wegig
```

---

## ▶️ Passo 4: Rodar o App por Flavor

### 4.1 Modo Debug (desenvolvimento)

```bash
# DEV (logs completos, Firebase dev)
flutter run --flavor dev -t lib/main_dev.dart

# STAGING (logs + Crashlytics, Firebase staging)
flutter run --flavor staging -t lib/main_staging.dart

# PROD (sem logs, Firebase prod)
flutter run --flavor prod -t lib/main_prod.dart
```

### 4.2 Instalar no dispositivo específico

```bash
# Listar dispositivos
flutter devices

# Rodar em dispositivo específico
flutter run --flavor dev -t lib/main_dev.dart -d <device-id>
```

---

## 📦 Passo 5: Build de Release

### 5.1 Usar Script Automatizado (Recomendado)

```bash
# Produção: AAB (Google Play) com obfuscation
./scripts/build_release.sh prod

# Staging: APK para teste interno com obfuscation
./scripts/build_release.sh staging

# Dev: APK rápido sem obfuscation
./scripts/build_release.sh dev

# Especificar plataforma
./scripts/build_release.sh prod android
./scripts/build_release.sh staging ios
```

**Saída esperada:**

```
🚀 WeGig - Build Automatizado
========================================
ℹ️  Flavor: prod
ℹ️  Plataforma: all

Buildando: 🔴 PRODUCTION

📦 Building Android App Bundle - PRODUCTION
✅ Android App Bundle criado!
📁 build/app/outputs/bundle/prodRelease/app-prod-release.aab
🔒 Símbolos: build/symbols/prod/android-bundle/

📱 Building iOS - PRODUCTION
✅ iOS build criado!
📁 build/ios/iphoneos/Runner.app
🔒 Símbolos: build/symbols/prod/ios/

🎉 Build Concluído!
✅ Flavor: PRODUCTION
✅ Plataforma: all

🔒 Proteções de Segurança Aplicadas
✅ Ofuscação de código (--obfuscate)
✅ Símbolos de debug separados (--split-debug-info)
✅ ProGuard habilitado (Android)
```

### 5.2 Build Manual (alternativa)

```bash
# Android APK
flutter build apk --flavor prod --release --obfuscate \
  --split-debug-info=build/symbols/prod/android \
  --no-tree-shake-icons

# Android App Bundle (Google Play)
flutter build appbundle --flavor prod --release --obfuscate \
  --split-debug-info=build/symbols/prod/android-bundle \
  --no-tree-shake-icons

# iOS
flutter build ios --flavor prod --release --obfuscate \
  --split-debug-info=build/symbols/prod/ios \
  --no-tree-shake-icons
```

---

## 🧪 Passo 6: Testar Cada Flavor

### 6.1 Verificar Bundle ID

```bash
# Android: verificar package name no APK
aapt dump badging build/app/outputs/flutter-apk/app-dev-release.apk | grep package

# Esperado:
# dev: package: name='com.tosembanda.wegig.dev'
# staging: package: name='com.tosembanda.wegig.staging'
# prod: package: name='com.tosembanda.wegig'
```

### 6.2 Verificar Nome do App

Instale os 3 flavors no mesmo dispositivo e veja:

- **DEV:** ícone azul, nome "WeGig DEV"
- **STAGING:** ícone roxo, nome "WeGig STAGING"
- **PROD:** ícone oficial (coral), nome "WeGig"

### 6.3 Verificar Configurações

Adicione logs temporários em `main.dart`:

```dart
import 'package:wegig/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🎯 Flavor: ${AppConfig.appFlavor}');
  print('🔧 Ambiente: ${AppConfig.appEnv}');
  print('🔥 Firebase: ${AppConfig.firebaseProjectId}');
  print('📝 Logs: ${AppConfig.enableLogs}');
  print('💥 Crashlytics: ${AppConfig.enableCrashlytics}');

  // ... resto do código
}
```

---

## 🔧 Passo 7: Configurar VSCode / Android Studio

### 7.1 VSCode (`.vscode/launch.json`)

Crie configurações para rodar cada flavor:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "WeGig DEV",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "args": ["--flavor", "dev"]
    },
    {
      "name": "WeGig STAGING",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_staging.dart",
      "args": ["--flavor", "staging"]
    },
    {
      "name": "WeGig PROD",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "args": ["--flavor", "prod"]
    }
  ]
}
```

### 7.2 Android Studio

1. **Run → Edit Configurations**
2. **Add New Configuration** (3 vezes)
3. Configurar cada uma:
   - **Name:** WeGig DEV
   - **Dart entrypoint:** `lib/main_dev.dart`
   - **Build flavor:** `dev`

---

## 📊 Passo 8: CI/CD (GitHub Actions - Opcional)

Crie `.github/workflows/build.yml`:

```yaml
name: Build Multi-Flavor

on:
  push:
    branches: [main, develop]

jobs:
  build-android:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        flavor: [dev, staging, prod]
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 3.9.2

      - name: Install dependencies
        run: flutter pub get

      - name: Build APK
        run: |
          flutter build apk --flavor ${{ matrix.flavor }} --release \
            --obfuscate --split-debug-info=build/symbols/${{ matrix.flavor }}

      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: app-${{ matrix.flavor }}-release.apk
          path: build/app/outputs/flutter-apk/
```

---

## 🐛 Troubleshooting

### Erro: "Could not find google-services.json"

**Solução:** Coloque o arquivo na pasta correta:

```bash
android/app/src/dev/google-services.json
android/app/src/staging/google-services.json
android/app/src/prod/google-services.json
```

### Erro: "No Firebase App '[DEFAULT]' has been created"

**Solução:** Verifique se `firebase_options_{dev,staging,prod}.dart` existem e estão sendo importados corretamente.

### Erro: "Duplicate class found"

**Solução:** Limpe o build cache:

```bash
flutter clean
cd android && ./gradlew clean
cd ios && pod deintegrate && pod install
```

### Ícones não mudaram

**Solução:** Execute `flutter_flavorizr` novamente e reconstrua:

```bash
flutter pub run flutter_flavorizr
flutter clean
flutter run --flavor dev -t lib/main_dev.dart
```

---

## 📚 Referências

- [flutter_flavorizr](https://pub.dev/packages/flutter_flavorizr)
- [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
- [Android Build Flavors](https://developer.android.com/studio/build/build-variants)
- [iOS Build Schemes](https://developer.apple.com/documentation/xcode/build-system)

---

## ✅ Checklist Final

- [ ] `flutter pub run flutter_flavorizr` executado com sucesso
- [ ] 3 projetos Firebase criados (dev, staging, prod)
- [ ] Arquivos `google-services.json` e `GoogleService-Info.plist` copiados
- [ ] `firebase_options_{dev,staging,prod}.dart` gerados
- [ ] App roda com `flutter run --flavor dev -t lib/main_dev.dart`
- [ ] 3 flavors instalados simultaneamente no dispositivo
- [ ] Nomes e ícones diferentes para cada flavor
- [ ] Build de produção funciona: `./scripts/build_release.sh prod`
- [ ] Símbolos de debug salvos em `build/symbols/`
- [ ] Crashlytics configurado para staging/prod

---

**🎉 Pronto! Agora você tem 3 ambientes isolados funcionando perfeitamente.**
