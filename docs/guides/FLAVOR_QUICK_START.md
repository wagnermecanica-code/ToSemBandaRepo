# ⚡ Quick Start - Flavors WeGig

Comandos essenciais para setup e uso dos flavors.

---

## 🚀 Setup Inicial (Execute UMA vez)

```bash
# 1. Instalar dependências
cd /Users/wagneroliveira/to_sem_banda
flutter pub get

# 2. Gerar estrutura de flavors
flutter pub run flutter_flavorizr

# 3. Validar setup
./scripts/validate_flavors.sh
```

**⚠️ IMPORTANTE:** Após passo 2, você PRECISA configurar Firebase:

- Criar projetos `to-sem-banda-dev` e `to-sem-banda-staging`
- Baixar e copiar `google-services.json` e `GoogleService-Info.plist`
- Executar `flutterfire configure` para cada flavor (veja FLAVOR_SETUP_GUIDE.md)

---

## ▶️ Rodar App (Debug)

```bash
# DEV (desenvolvimento)
flutter run --flavor dev -t lib/main_dev.dart

# STAGING (homologação)
flutter run --flavor staging -t lib/main_staging.dart

# PROD (produção)
flutter run --flavor prod -t lib/main_prod.dart
```

---

## 📦 Build Release

```bash
# PRODUÇÃO (AAB otimizado + obfuscation)
./scripts/build_release.sh prod

# STAGING (APK para teste interno + obfuscation)
./scripts/build_release.sh staging

# DEV (APK rápido sem obfuscation)
./scripts/build_release.sh dev
```

**Especificar plataforma:**

```bash
./scripts/build_release.sh prod android    # Apenas Android
./scripts/build_release.sh staging ios     # Apenas iOS (macOS only)
./scripts/build_release.sh dev all         # Todas as plataformas
```

---

## 🧪 Testar Instalação de Múltiplos Flavors

```bash
# Instalar os 3 flavors no mesmo dispositivo
flutter run --flavor dev -t lib/main_dev.dart -d <device-id>
flutter run --flavor staging -t lib/main_staging.dart -d <device-id>
flutter run --flavor prod -t lib/main_prod.dart -d <device-id>

# Listar dispositivos
flutter devices
```

**Resultado esperado:**

- 3 apps instalados simultaneamente
- Nomes diferentes (WeGig DEV, WeGig STAGING, WeGig)
- Ícones diferentes (azul, roxo, coral)
- Bundle IDs únicos (.dev, .staging, sem sufixo)

---

## 🔍 Validar Configuração

```bash
# Verificar arquivos necessários
./scripts/validate_flavors.sh

# Verificar flavor atual no app (adicionar logs temporários)
# Em lib/main.dart:
print('🎯 Flavor: ${AppConfig.appFlavor}');
print('🔧 Ambiente: ${AppConfig.appEnv}');
print('🔥 Firebase: ${AppConfig.firebaseProjectId}');
```

---

## 🧹 Limpar Cache

```bash
# Flutter
flutter clean
flutter pub get

# Android
cd android && ./gradlew clean && cd ..

# iOS (macOS only)
cd ios && pod deintegrate && pod install && cd ..

# Completo
flutter clean && cd android && ./gradlew clean && cd ../ios && pod deintegrate && pod install && cd ..
```

---

## 📱 Build Manual (Alternativa ao Script)

### Android

```bash
# APK
flutter build apk --flavor dev --release

# App Bundle (Google Play)
flutter build appbundle --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/prod \
  --no-tree-shake-icons
```

### iOS (macOS only)

```bash
flutter build ios --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/prod \
  --no-tree-shake-icons
```

---

## 🔥 Firebase - Configuração Rápida

```bash
# Instalar Firebase CLI (se ainda não tiver)
npm install -g firebase-tools

# Login
firebase login

# Gerar firebase_options por flavor
flutterfire configure --project=to-sem-banda-dev \
  --out=lib/firebase_options_dev.dart \
  --ios-bundle-id=com.tosembanda.wegig.dev \
  --android-app-id=com.tosembanda.wegig.dev

flutterfire configure --project=to-sem-banda-staging \
  --out=lib/firebase_options_staging.dart \
  --ios-bundle-id=com.tosembanda.wegig.staging \
  --android-app-id=com.tosembanda.wegig.staging

flutterfire configure --project=to-sem-banda-83e19 \
  --out=lib/firebase_options_prod.dart \
  --ios-bundle-id=com.tosembanda.wegig \
  --android-app-id=com.tosembanda.wegig
```

---

## 📊 Verificar Bundle IDs no Build

```bash
# Android - verificar package name
aapt dump badging build/app/outputs/flutter-apk/app-dev-release.apk | grep package

# iOS - verificar Bundle ID (macOS only)
/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" build/ios/iphoneos/Runner.app/Info.plist
```

---

## 🐛 Troubleshooting

### Erro: "Could not find google-services.json"

```bash
# Verificar se arquivo existe
ls -la android/app/src/dev/google-services.json
ls -la android/app/src/staging/google-services.json
ls -la android/app/src/prod/google-services.json

# Criar estrutura de pastas se não existir
mkdir -p android/app/src/dev
mkdir -p android/app/src/staging
mkdir -p android/app/src/prod
```

### Erro: "No Firebase App '[DEFAULT]' has been created"

```bash
# Verificar se firebase_options existem
ls -la lib/firebase_options_dev.dart
ls -la lib/firebase_options_staging.dart
ls -la lib/firebase_options_prod.dart

# Gerar novamente com flutterfire configure (veja seção Firebase acima)
```

### Erro: "Duplicate class found"

```bash
# Limpar tudo
flutter clean
cd android && ./gradlew clean && cd ..
rm -rf build/
flutter pub get
```

### Ícones não mudaram

```bash
# Re-gerar com flavorizr
flutter pub run flutter_flavorizr
flutter clean
flutter run --flavor dev -t lib/main_dev.dart
```

---

## 📚 Referências Rápidas

- **Guia Completo:** `cat FLAVOR_SETUP_GUIDE.md`
- **Status da Implementação:** `cat FLAVOR_IMPLEMENTATION_COMPLETE.md`
- **README Atualizado:** `cat README.md`
- **Validar Setup:** `./scripts/validate_flavors.sh`
- **Build Automatizado:** `./scripts/build_release.sh prod`

---

## ✅ Checklist Mínimo

Antes de fazer o primeiro build de produção:

- [ ] `flutter pub get` executado
- [ ] `flutter pub run flutter_flavorizr` executado
- [ ] 3 projetos Firebase criados
- [ ] Arquivos Firebase copiados (6 arquivos: 3 Android + 3 iOS)
- [ ] `firebase_options_{dev,staging,prod}.dart` gerados
- [ ] `./scripts/validate_flavors.sh` passou sem erros
- [ ] `flutter run --flavor dev -t lib/main_dev.dart` funciona
- [ ] `./scripts/build_release.sh prod` gera AAB com sucesso

---

**🎯 Pronto para produção em 3 comandos:**

```bash
flutter pub get
flutter pub run flutter_flavorizr
./scripts/build_release.sh prod
```

(Após configurar Firebase, claro! 😉)
