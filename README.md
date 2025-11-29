# WeGig

App Flutter para conectar músicos e bandas usando arquitetura multi-perfil estilo Instagram.

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20Storage-FFCA28?logo=firebase)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-3.x-00A699)](https://riverpod.dev)

## 🎯 Visão Geral

**WeGig** é uma plataforma social para músicos e bandas se encontrarem através de busca geoespacial, posts efêmeros (30 dias) e mensagens em tempo real. Cada usuário pode ter múltiplos perfis (músico ou banda), alternando entre eles como no Instagram.

**Stack Principal:**

- **Frontend:** Flutter 3.9.2+, Dart 3.5+
- **Backend:** Firebase (Firestore, Auth, Storage, Cloud Functions)
- **State Management:** Riverpod 3.x (AsyncNotifier pattern)
- **Mapas:** Google Maps, Geolocator
- **Cloud Functions:** Node.js (notificações de proximidade)

---

## ✨ Funcionalidades Principais

### 🔐 Autenticação Multi-Perfil

- Login via email/senha ou Google Sign-In
- Cada usuário Firebase pode ter múltiplos perfis (músico/banda)
- Troca de perfil instantânea estilo Instagram
- Isolamento completo de dados entre perfis

### 🗺️ Busca Geoespacial

- Mapa interativo com markers customizados
- Filtro de posts por proximidade (raio ajustável)
- Geração automática de cidade via reverse geocoding
- Pagination de posts com `startAfterDocument`
- Cache de markers (95% mais rápido)

### 📝 Posts Efêmeros

- Validade de 30 dias (expiração automática)
- Filtros por tipo (músico/banda), gêneros, instrumentos
- Galeria de imagens (até 9 fotos)
- Carrossel com navegação horizontal
- Compressão de imagens em isolate (evita freeze de UI)

### 💬 Chat em Tempo Real

- Mensagens instantâneas entre perfis
- Contador de não lidas por perfil
- Marcação automática como lida ao abrir conversa
- Lazy loading de streams (só carrega quando tab é acessada)

### 🔔 Notificações

- **Proximidade:** Cloud Function detecta novos posts no raio configurado (5-100km)
- **Interesses:** Notifica quando alguém demonstra interesse no seu post
- Badge de não lidas em tempo real
- Streams otimizados com `distinctUntilChanged`

### 🎨 Design System

- Material 3 + tema customizado
- Cor primária: Teal `#00A699`
- Tipografia: Inter (Regular, Medium, SemiBold, Bold)
- Dark mode opcional (via `.env`)

---

## 🏗️ Arquitetura

### 🎭 Flavors (Dev / Staging / Production)

O projeto usa **flutter_flavorizr** para gerenciar 3 ambientes isolados:

| Flavor      | App Name      | Bundle ID                      | Firebase             | Logs   | Obfuscation |
| ----------- | ------------- | ------------------------------ | -------------------- | ------ | ----------- |
| **dev**     | WeGig DEV     | `com.tosembanda.wegig.dev`     | to-sem-banda-dev     | ✅ On  | ❌ Off      |
| **staging** | WeGig STAGING | `com.tosembanda.wegig.staging` | to-sem-banda-staging | ✅ On  | ✅ On       |
| **prod**    | WeGig         | `com.tosembanda.wegig`         | to-sem-banda-83e19   | ❌ Off | ✅ On       |

**Rodar por flavor:**

```bash
# Desenvolvimento (dev)
flutter run --flavor dev -t lib/main_dev.dart

# Homologação (staging)
flutter run --flavor staging -t lib/main_staging.dart

# Produção (prod)
flutter run --flavor prod -t lib/main_prod.dart
```

**Build automatizado:**

```bash
# Produção (AAB + obfuscation)
./scripts/build_release.sh prod

# Staging (APK para teste interno)
./scripts/build_release.sh staging

# Dev (APK rápido sem obfuscation)
./scripts/build_release.sh dev

# Especificar plataforma
./scripts/build_release.sh prod android
./scripts/build_release.sh staging ios
```

**Configuração por flavor:**

```dart
import 'package:wegig/config/app_config.dart';

// Verifica ambiente
if (AppConfig.isDevelopment) {
  debugPrint('Rodando em DEV');
}

// Usa configurações do flavor
final apiUrl = AppConfig.apiBaseUrl;
final enableLogs = AppConfig.enableLogs;
```

**Arquivos de configuração:**

- `lib/config/dev_config.dart` - Dev (logs ligados)
- `lib/config/staging_config.dart` - Staging (logs + Crashlytics)
- `lib/config/prod_config.dart` - Produção (logs desligados)
- `lib/config/app_config.dart` - Centraliza acesso aos configs

---

### Multi-Perfil (Instagram-style)

**Data Model:**

```
users/{uid}
  ├─ activeProfileId: String
  └─ email: String

profiles/{profileId}
  ├─ uid: String (Firebase Auth UID)
  ├─ name: String
  ├─ isBand: Boolean
  ├─ location: GeoPoint (obrigatório)
  ├─ city: String
  ├─ instruments: List<String>
  ├─ genres: List<String>
  └─ photoUrl: String
```

**State Management:**

```dart
// SEMPRE ler do Riverpod (nunca cache local)
final profileState = ref.read(profileProvider).value?.activeProfile;

// Invalidar cache após troca de perfil
ref.invalidate(profileProvider);
```

**Ownership Model:**

- Firestore rules: `resource.data.uid == request.auth.uid` (Firebase UID)
- App logic: `authorProfileId == activeProfile.profileId` (isolamento de perfis)

### Posts & Queries

**Campos Obrigatórios:**

```dart
{
  location: GeoPoint(lat, lng),        // Geosearch
  expiresAt: Timestamp(now + 30 days), // Auto-cleanup
  authorProfileId: String,              // Autor do post
  city: String,                         // Reverse geocoding
  createdAt: Timestamp,
  type: 'musician' | 'band'
}
```

**Query Padrão (todas queries devem seguir):**

```dart
FirebaseFirestore.instance.collection('posts')
  .where('expiresAt', isGreaterThan: Timestamp.now())
  // NÃO filtrar próprio perfil - usuário deve ver seus posts
  .orderBy('expiresAt')
  .orderBy('createdAt', descending: true)
  .limit(50);
```

**Indexes Necessários:**

```json
// firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "expiresAt", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
    // ... 12 outros indexes para filtros combinados
  ]
}
```

### Imagens (Performance Critical)

**❌ NUNCA usar `Image.network`** (memory leak + 80% mais lento)

**✅ SEMPRE usar:**

```dart
CachedNetworkImage(
  imageUrl: photoUrl,
  memCacheWidth: displayWidth * 2,  // Retina
  memCacheHeight: displayHeight * 2,
  placeholder: (_, __) => CircularProgressIndicator(),
  errorWidget: (_, __, ___) => Icon(Icons.error),
)
```

**Upload com Compressão (Isolate obrigatório):**

```dart
// Top-level function
Future<Uint8List> _compressImageIsolate(String path) async {
  final bytes = await File(path).readAsBytes();
  return await FlutterImageCompress.compressWithList(bytes, quality: 85);
}

// No StatefulWidget
final compressed = await compute(_compressImageIsolate, file.path);
```

### Cloud Functions (Notificações de Proximidade)

**Trigger:** `onCreate('posts/{postId}')`  
**Region:** `southamerica-east1` (São Paulo)

**Lógica:**

1. Query profiles com `notificationRadiusEnabled == true`
2. Calcular distância Haversine do post
3. Criar notificação se distância ≤ `notificationRadius` (default 20km)
4. Batch write max 500 notificações por post

**Deploy:**

```bash
cd functions
npm install
firebase deploy --only functions
firebase functions:log  # Monitor
```

---

## 🚀 Setup & Execução

### Pré-requisitos

- Flutter SDK 3.9.2+
- Dart SDK 3.5+
- Xcode 15+ (iOS) ou Android Studio (Android)
- Firebase CLI
- Node.js 18+ (Cloud Functions)

### Instalação

1. **Clone & dependências:**

```bash
git clone https://github.com/wagnermecanica-code/ToSemBandaRepo.git
cd to_sem_banda
flutter pub get
```

2. **Firebase config:**

   - Baixe `google-services.json` (Android) e `GoogleService-Info.plist` (iOS)
   - Coloque em `android/app/` e `ios/Runner/`

3. **Environment variables (.env):**

```bash
cp .env.example .env
# Edite com suas chaves
```

Variáveis obrigatórias:

```
GOOGLE_MAPS_API_KEY=your_key_here
APP_ENV=development
FIREBASE_PROJECT_ID=your-project-id
```

4. **Firestore indexes:**

```bash
firebase deploy --only firestore:indexes
# Aguarde conclusão no console Firebase
firebase deploy --only firestore:rules
```

5. **Cloud Functions:**

```bash
cd functions
npm install
firebase deploy --only functions
```

6. **Run:**

```bash
flutter run
# ou
flutter run --dart-define-from-file=.env
```

---

## 📁 Estrutura de Arquivos

```
lib/
├─ main.dart                    # Entry point + Firebase init
├─ firebase_options.dart        # Firebase config auto-gerado
├─ models/
│  ├─ profile.dart              # Profile data model
│  ├─ post.dart                 # Post data model
│  └─ search_params.dart        # Search filters
├─ pages/
│  ├─ auth_page.dart            # Login/cadastro
│  ├─ home_page.dart            # Mapa + posts (1213 linhas)
│  ├─ post_page.dart            # Criar post (940 linhas)
│  ├─ messages_page.dart        # Lista de chats
│  ├─ chat_detail_page.dart     # Chat em tempo real
│  ├─ view_profile_page.dart    # Visualizar perfil
│  ├─ edit_profile_page.dart    # Editar perfil
│  ├─ settings_page.dart        # Configurações
│  └─ bottom_nav_scaffold.dart  # Bottom navigation
├─ providers/
│  ├─ profile_provider.dart     # AsyncNotifier (perfil ativo)
│  └─ post_provider.dart        # Posts state
├─ repositories/
│  ├─ profile_repository.dart   # Profile CRUD
│  └─ post_repository.dart      # Post CRUD + geosearch
├─ services/
│  ├─ env_service.dart          # .env loader
│  ├─ marker_cache_service.dart # Map marker cache
│  ├─ notification_service.dart # Push notifications
│  └─ message_service.dart      # Chat logic
├─ theme/
│  ├─ app_theme.dart            # Material 3 theme
│  ├─ app_colors.dart           # Color palette
│  └─ app_typography.dart       # Text styles
├─ utils/
│  └─ debouncer.dart            # Debouncer & Throttler
└─ widgets/
   ├─ profile_switcher_bottom_sheet.dart
   └─ app_loading_overlay.dart

functions/
└─ index.js                     # Cloud Functions (190 linhas)

firestore.rules                 # Security rules
firestore.indexes.json          # 13 composite indexes
```

---

## 🐛 Troubleshooting

| Problema                     | Solução                                                                   |
| ---------------------------- | ------------------------------------------------------------------------- |
| `Query/Index Errors`         | Deploy indexes: `firebase deploy --only firestore:indexes`                |
| `Missing Location Data`      | Execute: `scripts/check_posts.sh`                                         |
| `Profile State Bugs`         | Sempre usar `ref.read(profileProvider).value?.activeProfile`              |
| `Image Upload Freeze`        | Certificar padrão `compute()` isolate (ver `post_page.dart:442`)          |
| `Cloud Functions Not Firing` | Verificar logs: `firebase functions:log --only onPostCreated`             |
| `LateInitializationError`    | Reiniciar app (hot restart) - Riverpod não suporta hot reload após logout |

---

## 📚 Documentação Adicional

- **[Copilot Instructions](.github/copilot-instructions.md)** - Guia completo de arquitetura
- **[Cloud Functions](NEARBY_POST_NOTIFICATIONS.md)** - Notificações de proximidade
- **[Performance](SESSION_10_CODE_QUALITY_OPTIMIZATION.md)** - Otimizações aplicadas
- **[Wireframe](WIREFRAME.md)** - Design system e UI/UX

---

## 🔧 Build & Deploy

### iOS

```bash
flutter build ios --release
# Xcode → Product → Archive → Distribute
```

### Android

```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

### Firestore

```bash
firebase deploy --only firestore:indexes
firebase deploy --only firestore:rules
```

### Cloud Functions

```bash
cd functions
firebase deploy --only functions
```

---

## 📊 Status do Projeto

### Features Completas

- ✅ Auth multi-perfil (Firebase + Google)
- ✅ Posts efêmeros com geolocalização
- ✅ Chat em tempo real
- ✅ Notificações de proximidade (Cloud Functions)
- ✅ Busca geoespacial com filtros
- ✅ Galeria de imagens + compressão
- ✅ Cache de markers (performance)
- ✅ Design system Material 3
- ✅ Push notifications FCM (100% funcional)

### Refatoração em Andamento (29/11/2025)

- ✅ **Post Feature:** 0 erros (100% completo - Freezed removed)
- 🚧 **Profile Feature:** 60 erros (próximo target)
- 🚧 **Notifications Feature:** 40 erros
- 🚧 **Auth Feature:** 10 erros
- 🚧 **Outros:** 4 erros

**Total:** 1183 erros → Meta: 0 erros  
**Ver detalhes:** `SESSION_ATUAL_29_NOV_2025.md`

---

## 👥 Contribuindo

1. Fork o projeto
2. Crie uma branch: `git checkout -b feature/nova-funcionalidade`
3. Commit: `git commit -m 'Add: nova funcionalidade'`
4. Push: `git push origin feature/nova-funcionalidade`
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja [LICENSE](LICENSE) para mais detalhes.

---

## 📞 Contato

**Wagner Oliveira**  
📧 wagner_mecanica@hotmail.com  
🔗 [GitHub](https://github.com/wagnermecanica-code)
