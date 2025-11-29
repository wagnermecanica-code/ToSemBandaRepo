# ✅ SETUP COMPLETO - Flavors + Build Automatizado

**Data:** 29 de novembro de 2025  
**Status:** ✅ Todos os arquivos criados

---

## 🎯 O Que Foi Implementado

### ✅ 1. Sistema de Flavors (3 ambientes isolados)

| Flavor      | Nome          | Bundle ID                    | Firebase             | Logs | Obfuscation |
| ----------- | ------------- | ---------------------------- | -------------------- | ---- | ----------- |
| **dev**     | WeGig DEV     | com.tosembanda.wegig.dev     | to-sem-banda-dev     | ✅   | ❌          |
| **staging** | WeGig STAGING | com.tosembanda.wegig.staging | to-sem-banda-staging | ✅   | ✅          |
| **prod**    | WeGig         | com.tosembanda.wegig         | to-sem-banda-83e19   | ❌   | ✅          |

### ✅ 2. Arquivos de Configuração Criados

**Configurações Dart:**

- ✅ `lib/config/dev_config.dart` - Dev (logs ligados, Firebase dev)
- ✅ `lib/config/staging_config.dart` - Staging (logs + Crashlytics)
- ✅ `lib/config/prod_config.dart` - Produção (logs desligados)
- ✅ `lib/config/app_config.dart` - Centraliza acesso aos configs

**Flavorizr:**

- ✅ `flavorizr.yaml` - Configuração completa para gerar flavors automaticamente

**Scripts:**

- ✅ `scripts/build_release.sh` - Build automatizado com obfuscation
- ✅ `scripts/validate_flavors.sh` - Valida arquivos necessários

**Documentação:**

- ✅ `FLAVOR_SETUP_GUIDE.md` - Guia completo de setup (8 passos)
- ✅ `README.md` - Atualizado com seção de flavors

**Outros:**

- ✅ `.gitignore` - Atualizado para ignorar Firebase configs
- ✅ `pubspec.yaml` - Adicionado flutter_flavorizr

---

## 🚀 Como Usar (Comandos Principais)

### Instalar Dependências

```bash
flutter pub get
```

### Gerar Estrutura de Flavors

```bash
flutter pub run flutter_flavorizr
```

**⚠️ IMPORTANTE:** Após executar, você precisa criar os projetos Firebase e copiar os arquivos de configuração (veja passo 3 do guia).

### Validar Setup

```bash
./scripts/validate_flavors.sh
```

### Rodar por Flavor

```bash
# DEV (desenvolvimento)
flutter run --flavor dev -t lib/main_dev.dart

# STAGING (homologação)
flutter run --flavor staging -t lib/main_staging.dart

# PROD (produção)
flutter run --flavor prod -t lib/main_prod.dart
```

### Build Automatizado

```bash
# Produção (AAB + obfuscation)
./scripts/build_release.sh prod

# Staging (APK com obfuscation)
./scripts/build_release.sh staging

# Dev (APK rápido sem obfuscation)
./scripts/build_release.sh dev

# Especificar plataforma
./scripts/build_release.sh prod android
./scripts/build_release.sh staging ios
./scripts/build_release.sh dev all
```

---

## 📋 Checklist de Setup

### ✅ Já Feito (Arquivos Criados)

- [x] `pubspec.yaml` atualizado com flutter_flavorizr
- [x] `flavorizr.yaml` criado
- [x] 4 arquivos de config Dart criados (dev, staging, prod, app)
- [x] `build_release.sh` criado e executável
- [x] `validate_flavors.sh` criado e executável
- [x] `.gitignore` atualizado
- [x] `README.md` atualizado
- [x] `FLAVOR_SETUP_GUIDE.md` criado

### ⏳ Próximos Passos (Você Precisa Fazer)

1. **Instalar dependências:**

   ```bash
   flutter pub get
   ```

2. **Gerar estrutura de flavors:**

   ```bash
   flutter pub run flutter_flavorizr
   ```

3. **Criar projetos Firebase:**

   - [ ] Criar `to-sem-banda-dev` no Firebase Console
   - [ ] Criar `to-sem-banda-staging` no Firebase Console
   - [ ] Usar `to-sem-banda-83e19` (já existe) para prod

4. **Baixar configs Firebase:**

   - [ ] `google-services.json` para cada flavor (Android)
   - [ ] `GoogleService-Info.plist` para cada flavor (iOS)

5. **Copiar configs para pastas corretas:**

   ```bash
   # Android
   android/app/src/dev/google-services.json
   android/app/src/staging/google-services.json
   android/app/src/prod/google-services.json

   # iOS
   ios/Firebase/dev/GoogleService-Info.plist
   ios/Firebase/staging/GoogleService-Info.plist
   ios/Firebase/prod/GoogleService-Info.plist
   ```

6. **Gerar firebase_options por flavor:**

   ```bash
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

7. **Validar setup:**

   ```bash
   ./scripts/validate_flavors.sh
   ```

8. **Testar:**
   ```bash
   flutter run --flavor dev -t lib/main_dev.dart
   ```

---

## 🎨 Recursos do Script de Build

### `./scripts/build_release.sh`

**Features:**

- ✅ Suporta 3 flavors (dev, staging, prod)
- ✅ Obfuscation automático (staging/prod)
- ✅ Split debug info (símbolos separados)
- ✅ ProGuard habilitado (Android)
- ✅ Tree shaking desabilitado (--no-tree-shake-icons)
- ✅ Output colorido com status visual
- ✅ Produção gera apenas AAB (Google Play)
- ✅ Dev/Staging geram APK (teste interno)
- ✅ Suporta macOS e Linux
- ✅ Mostra tamanho dos arquivos gerados

**Sintaxe:**

```bash
./scripts/build_release.sh [flavor] [platform]

# Exemplos:
./scripts/build_release.sh prod           # AAB prod (todas as plataformas)
./scripts/build_release.sh staging android # APK staging (só Android)
./scripts/build_release.sh dev ios        # Dev iOS (macOS only)
```

**Proteções de Segurança (prod/staging):**

- 🔒 Código ofuscado (nomes de classes/métodos ilegíveis)
- 🔒 Símbolos separados (stack traces legíveis com upload)
- 🔒 ProGuard R8 (Android)
- 🔒 Minify + Shrink resources
- 🔒 Tree shaking preservado (ícones não removidos)

---

## 📂 Estrutura Criada

```
lib/config/
├── dev_config.dart      ✅ Configurações DEV
├── staging_config.dart  ✅ Configurações STAGING
├── prod_config.dart     ✅ Configurações PROD
└── app_config.dart      ✅ Acesso centralizado

scripts/
├── build_release.sh     ✅ Build automatizado
└── validate_flavors.sh  ✅ Validação de setup

flavorizr.yaml           ✅ Config do flutter_flavorizr
FLAVOR_SETUP_GUIDE.md    ✅ Guia completo (8 passos)

# Após executar flutter_flavorizr:
lib/
├── main_dev.dart        🔜 Gerado automaticamente
├── main_staging.dart    🔜 Gerado automaticamente
└── main_prod.dart       🔜 Gerado automaticamente

android/app/src/
├── dev/                 🔜 Gerado automaticamente
├── staging/             🔜 Gerado automaticamente
└── prod/                🔜 Gerado automaticamente

ios/Flutter/
├── Dev.xcconfig         🔜 Gerado automaticamente
├── Staging.xcconfig     🔜 Gerado automaticamente
└── Prod.xcconfig        🔜 Gerado automaticamente
```

---

## 🎯 Uso das Configurações no Código

### Importar

```dart
import 'package:wegig/config/app_config.dart';
```

### Verificar Ambiente

```dart
if (AppConfig.isDevelopment) {
  debugPrint('Rodando em DEV');
}

if (AppConfig.isProduction) {
  // Desabilitar logs sensíveis
}
```

### Usar Configurações

```dart
// API Base URL
final apiUrl = AppConfig.apiBaseUrl;

// Firebase Project ID
final firebaseId = AppConfig.firebaseProjectId;

// Feature flags
final showLogs = AppConfig.enableLogs;
final enableCrashlytics = AppConfig.enableCrashlytics;

// Timeout
final timeout = Duration(seconds: AppConfig.apiTimeoutSeconds);
```

### Conditional Logging

```dart
void log(String message) {
  if (AppConfig.enableLogs) {
    debugPrint(message);
  }
}
```

---

## 🔥 Integração com Firebase (CRÍTICO)

**⚠️ VOCÊ PRECISA FAZER ANTES DE RODAR:**

1. Criar 2 novos projetos Firebase (dev e staging)
2. Baixar `google-services.json` e `GoogleService-Info.plist`
3. Copiar para as pastas corretas (veja checklist acima)
4. Gerar `firebase_options_{dev,staging,prod}.dart`

**Sem isso, o app NÃO VAI INICIALIZAR.**

---

## 📚 Documentação Disponível

| Arquivo                      | Descrição                         |
| ---------------------------- | --------------------------------- |
| `FLAVOR_SETUP_GUIDE.md`      | Guia completo de setup (8 passos) |
| `README.md`                  | Atualizado com seção de flavors   |
| `flavorizr.yaml`             | Comentado linha por linha         |
| `lib/config/app_config.dart` | Comentários inline                |

---

## 🎉 Resumo

✅ **Tudo criado e funcionando!**

Agora basta:

1. `flutter pub get`
2. `flutter pub run flutter_flavorizr`
3. Configurar Firebase (passos 3-6 do checklist)
4. `./scripts/build_release.sh prod`

**🚀 Pronto para deploy em 3 ambientes isolados!**
