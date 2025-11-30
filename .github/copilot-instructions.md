# WeGig (Tô Sem Banda) – AI Coding Agent Guide

**Flutter monorepo social app** connecting musicians and bands via geospatial search, ephemeral posts, real-time chat, and proximity notifications.

**Stack:** Flutter 3.9.2+, Dart 3.6+, Firebase (Auth/Firestore/Storage/Functions), Riverpod 2.x, Google Maps, Melos monorepo  
**Architecture:** Clean Architecture + Feature-First + Monorepo (packages/app + packages/core_ui)

**Last Updated:** November 30, 2025

---

## ⚡ Quick Reference (Most Common Commands)

```bash
# Monorepo Management (Melos - REQUIRED)
melos bootstrap                          # Install all dependencies (run first!)
melos get                                # Pub get for all packages
melos analyze                            # Analyze all packages
melos test                               # Run tests in all packages
melos run build_runner                   # Run build_runner (Freezed/JsonSerializable)

# Development (run from packages/app/)
flutter run --flavor dev -t lib/main_dev.dart        # Dev environment
flutter run --flavor staging -t lib/main_staging.dart # Staging
flutter run --flavor prod -t lib/main_prod.dart      # Production
flutter run --verbose                    # Debug with detailed output
flutter clean && melos get               # Nuclear option for dependency issues

# Testing & Validation
flutter test                             # Run unit tests (53 tests)
scripts/check_posts.sh                   # Audit Firestore posts for missing fields
firebase functions:log                   # Monitor Cloud Functions execution
firebase functions:log --only notifyNearbyPosts  # Filter specific function

# Deployment
firebase deploy --only firestore:indexes # Deploy indexes FIRST (wait for "Enabled")
firebase deploy --only firestore:rules   # Then deploy rules
cd functions && firebase deploy --only functions  # Deploy Cloud Functions
./scripts/build_release.sh prod          # Build obfuscated release (Android/iOS)

# Troubleshooting
flutter logs                             # Real-time app logs
firebase functions:log | grep "Rate limit"  # Check rate limiting
Hot Restart: ⌘+Shift+\ (macOS)           # Required after auth changes
```

---

## 🎯 Project Overview

Social platform with **Instagram-style multi-profile architecture** where each user can have multiple profiles (musician/band) with complete data isolation. Posts expire after 30 days, Cloud Functions trigger proximity notifications, and all images use `CachedNetworkImage` for 80% performance boost.

**Project Names:**

- **App:** WeGig (user-facing)
- **Repo:** Tô Sem Banda / ToSemBandaRepo (codebase)
- **Firebase Project:** `to-sem-banda-83e19`

**Monorepo Structure:**

```
packages/
  ├── app/              # Application layer (features, Firebase, routing)
  │   ├── lib/features/ # 7 features with Clean Architecture
  │   │   ├── auth/     # Firebase Auth, Google/Apple Sign-In
  │   │   ├── profile/  # Multi-profile CRUD (Instagram-style)
  │   │   ├── home/     # Map, geosearch, post feed
  │   │   ├── post/     # Create/edit posts, image upload
  │   │   ├── messages/ # Real-time chat, conversations
  │   │   ├── notifications/ # Proximity & interest notifications
  │   │   └── settings/ # User preferences
  │   └── lib/app/router/ # Type-safe GoRouter (go_router_builder)
  └── core_ui/          # Shared layer (entities, theme, widgets, DI)
      ├── lib/features/ # Shared entities (ProfileEntity, PostEntity, etc)
      ├── lib/theme/    # Design system (AppColors, AppTypography)
      ├── lib/di/       # Global Riverpod providers
      └── lib/navigation/ # BottomNavScaffold
```

**Critical:** Always run `melos bootstrap` before any development. Monorepo dependencies require Melos orchestration.

---

## 🏗️ Critical Architecture Patterns

### 1. Multi-Profile System (Instagram-Style)

**Data Model:**

```
users/{uid}                    # Firebase Auth level
  └─ activeProfileId: String

profiles/{profileId}           # Profile level (isolated identities)
  ├─ uid: String               # Owner Firebase UID
  ├─ name, isBand, location
  └─ instruments, genres, bio
```

**State Management (CRITICAL - most common bug source):**

```dart
// ✅ ALWAYS read fresh from provider (NEVER cache in local variables)
final profile = ref.read(profileProvider).value?.activeProfile;

// ✅ After profile switch, MUST invalidate ALL dependent providers
ref.invalidate(profileProvider);
ref.invalidate(postProvider);
ref.invalidate(unreadNotificationCountProvider);
ref.invalidate(unreadMessageCountProvider);

// ✅ Listen to profile changes reactively (main.dart pattern)
ref.listenManual(profileStreamProvider, (previous, next) {
  if (previous?.activeProfile?.profileId != next.value?.activeProfile?.profileId) {
    // Profile switched - invalidate dependent state
  }
});
```

**Ownership Model:**

- **Firestore rules:** `resource.data.uid == request.auth.uid` (Firebase UID level)
- **App logic:** `authorProfileId == activeProfile.profileId` (profile isolation)
- **Posts query:** User sees ALL posts including own (filtering happens in UI if needed)

**Memory Leak Prevention:**

```dart
// ProfileNotifier pattern (SESSION_14)
final StreamController<ProfileState> _streamController = StreamController.broadcast();

@override
FutureOr<ProfileState> build() async {
  ref.onDispose(() => _streamController.close()); // ✅ Always close streams
  return _loadProfiles();
}
```

**Files:** `packages/core_ui/lib/di/profile_providers.dart`, `packages/app/lib/features/profile/data/repositories/profile_repository_impl.dart`, `packages/app/lib/features/profile/domain/usecases/*.dart`

---

### 2. Clean Architecture (Repository-Service-Provider)

**Pattern:** Repository = CRUD only | Service = Business Logic | Provider = State Management

```dart
// 1. Repository (data access, atomic transactions)
abstract class IProfileRepository {
  Future<List<Profile>> getAllProfiles();
  Future<void> deleteProfile(String id, {String? newActiveProfileId}); // Atomic
}

// 2. Service (validations, business rules, analytics)
abstract class IProfileService {
  Future<ProfileResult> createProfile(Profile profile);  // Validates 5-profile limit
  Future<ProfileResult> validateProfile(Profile profile); // Name 2-50 chars, etc
}

// 3. Sealed class results (type-safe pattern matching)
sealed class ProfileResult {}
class ProfileSuccess extends ProfileResult { final Profile profile; }
class ProfileFailure extends ProfileResult { final String message; }
class ProfileValidationError extends ProfileResult { final Map<String, String> errors; }

// 4. UI pattern matching (exhaustive - compiler enforces all cases)
final result = await ref.read(profileProvider.notifier).deleteProfile(id);
switch (result) {
  case ProfileSuccess(:final profile):
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perfil excluído: ${profile.name}')),
    );
  case ProfileFailure(:final message):
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $message'), backgroundColor: Colors.red),
    );
  case ProfileNotFound():
    // Handle not found case
}

// Alternative: Extension method pattern (packages/core_ui/lib/auth_result.dart)
final authResult = await AuthService.signIn(email, password);
authResult.when(
  success: (auth) => Navigator.pushReplacement(...),
  failure: (auth) => showErrorDialog(auth.message),
  cancelled: (_) => debugPrint('User cancelled'),
);
```

**Why:** Atomic transactions prevent orphaned `activeProfileId` refs. See `SESSION_14_MULTI_PROFILE_REFACTORING.md` for migration guide.

**Why:** Atomic transactions prevent orphaned `activeProfileId` refs. See `TODO_CLEAN_ARCHITECTURE_MONOREPO.md` (100% complete) for migration details.

**Monorepo Package Separation:**

- **Entities (core_ui):** `packages/core_ui/lib/features/*/domain/entities/*.dart` (ProfileEntity, PostEntity, etc)
- **Repository Interfaces (app):** `packages/app/lib/features/*/domain/repositories/*.dart`
- **Repository Implementations (app):** `packages/app/lib/features/*/data/repositories/*.dart`
- **DataSources (app):** `packages/app/lib/features/*/data/datasources/*.dart` (Firebase operations)
- **Use Cases (app):** `packages/app/lib/features/*/domain/usecases/*.dart` (business logic)
- **Result Types (core_ui):** `packages/core_ui/lib/{auth,profile,post,messages}_result.dart`

**Files:** Feature folders under `packages/app/lib/features/`, entities in `packages/core_ui/lib/features/`

---

### 3. Firestore Queries & Indexes

**Universal Query Pattern (ALL post queries MUST follow):**

```dart
FirebaseFirestore.instance.collection('posts')
  .where('expiresAt', isGreaterThan: Timestamp.now())  // ⚠️ REQUIRED: exclude expired
  .orderBy('expiresAt')                                // ⚠️ REQUIRED: for composite index
  .orderBy('createdAt', descending: true)
  .limit(50);

// Pagination (NEVER skip)
if (_lastDoc != null) query = query.startAfterDocument(_lastDoc);
```

**Mandatory Post Fields:**

```dart
{
  location: GeoPoint(lat, lng),         // Geosearch (never 0,0)
  expiresAt: Timestamp(now + 30 days),  // Auto-cleanup
  authorProfileId: String,              // Profile that created post
  authorUid: String,                    // Firebase Auth UID
  city: String,                         // From reverse geocoding
  createdAt: Timestamp
}
```

**Index Deployment (CRITICAL ORDER):**

```bash
# 1. Deploy indexes FIRST, wait for Firebase Console to show "Enabled"
firebase deploy --only firestore:indexes

# 2. THEN deploy rules (prevents "index required" errors)
firebase deploy --only firestore:rules
```

**Debugging:** Firestore errors provide direct index creation links. See `firestore.indexes.json` (15 composite indexes for posts, notifications, conversations, interests). Run `scripts/check_posts.sh` to audit missing fields.

**Monorepo Context:** All Firebase configuration lives at root level (not in packages/app). Firestore operations are in `packages/app/lib/features/*/data/datasources/`.

**Files:** `firestore.indexes.json`, `firestore.rules`, `scripts/check_posts.sh`

---

### 4. Image Handling (Performance Critical)

**❌ NEVER use:** `Image.network` or `NetworkImage` (causes memory leaks, 80% slower, no cache)

**✅ ALWAYS use `CachedNetworkImage`:**

```dart
// All remote images
CachedNetworkImage(
  imageUrl: photoUrl,
  memCacheWidth: displayWidth * 2,    // Retina optimization
  memCacheHeight: displayHeight * 2,
  placeholder: (_, __) => CircularProgressIndicator(),
  errorWidget: (_, __, ___) => Icon(Icons.error),
)

// Avatars
CircleAvatar(
  backgroundImage: CachedNetworkImageProvider(photoUrl),
)
```

**Upload Compression (MUST use isolate to avoid 2-5s UI freeze):**

```dart
// Top-level function (required for compute())
Future<Uint8List> _compressImageIsolate(String path) async {
  final bytes = await File(path).readAsBytes();
  return await FlutterImageCompress.compressWithList(bytes, quality: 85);
}

// In widget - offloads heavy work to separate isolate
final compressed = await compute(_compressImageIsolate, file.path);
await FirebaseStorage.instance.ref(path).putData(compressed);
```

**Reference:** `packages/app/lib/features/post/presentation/pages/post_page.dart` (compression isolate), all `CachedNetworkImage` usage verified via grep.

---

### 5. Performance Optimizations

**Debouncing (NEVER use raw Timers):**

```dart
final _debouncer = Debouncer(milliseconds: 300);   // Search inputs
final _throttler = Throttler(milliseconds: 100);    // Scroll handlers

_debouncer.run(() => _performSearch(query));  // Cancels previous calls
_throttler.run(() => _updateMarkers());       // Max 1 execution per 100ms
```

**Map Markers (95% faster - 40ms → 2ms per marker):**

```dart
// Pre-warm cache in main.dart before app loads
await MarkerCacheService().warmupCache();

// Use cached BitmapDescriptors (Canvas API pre-rendered)
final marker = await MarkerCacheService().getMarker('musician', isActive: true);
```

**Lazy Stream Initialization (bottom_nav_scaffold.dart):**

```dart
bool _notificationsStreamInitialized = false;

void _onTabChanged() {
  if (_currentIndexNotifier.value == 1 && !_notificationsStreamInitialized) {
    setState(() => _notificationsStreamInitialized = true); // Load stream on-demand
  }
}
```

**ValueNotifier for Navigation (prevents unnecessary rebuilds):**

```dart
// In BottomNavScaffold - avoids setState on entire scaffold
final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

// Listen to changes
_currentIndexNotifier.addListener(() {
  // React to navigation changes
});

// Update
_currentIndexNotifier.value = 2; // Navigate to Messages tab
```

**Stream Combination (rxdart for multiple sources):**

```dart
// notifications_page.dart - combines proximity + interest notifications
import 'package:rxdart/rxdart.dart';

Rx.combineLatest2<List<NotificationModel>, List<NotificationModel>, List<NotificationModel>>(
  proximityStream,
  interestStream,
  (proximity, interest) => [...proximity, ...interest]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
).distinctUntilChanged(); // Prevents duplicate emissions
```

**Logging:**

- ✅ Use `debugPrint()` (stripped in `--release` builds)
- ❌ Never use `print()` (persists in production, leaks data)

**Files:** `packages/core_ui/lib/utils/debouncer.dart`, `packages/app/lib/features/home/data/datasources/marker_cache_service.dart`, `packages/core_ui/lib/navigation/bottom_nav_scaffold.dart`, `packages/app/lib/features/notifications/presentation/pages/notifications_page.dart`

**Offline Support (CacheService - 24h expiration):**

```dart
// Save posts to SharedPreferences
await CacheService.cachePosts(posts);

// Retrieve cached posts (returns null if expired)
final cached = await CacheService.getCachedPosts();

// Clear all cache
await CacheService.clearCache();
```

**File:** `packages/app/lib/features/home/data/datasources/cache_service.dart` (used for offline mode, not critical for online-first UX)

---

## 🔐 Environment Configuration

**Setup (NEVER hardcode keys):**

```dart
// main.dart - BEFORE Firebase.initializeApp()
await EnvService.init();
final apiKey = EnvService.get('GOOGLE_MAPS_API_KEY');
```

**Required `.env` variables:**

```
GOOGLE_MAPS_API_KEY=your_key_here
APP_ENV=development
FIREBASE_PROJECT_ID=to-sem-banda-83e19
```

**File:** `packages/app/lib/config/env_service.dart` (loads `.env`, provides `isProduction`/`isDevelopment` flags)

---

## ☁️ Cloud Functions & Push Notifications

**Functions Deployed:**

1. **`notifyNearbyPosts`** - Proximity notifications (onCreate `posts/{postId}`)

   - Creates in-app notification
   - Sends push notification to nearby profiles
   - Uses Haversine distance calculation

2. **`sendInterestNotification`** - Interest notifications (onCreate `interests/{interestId}`)

   - Creates in-app notification
   - Sends push notification to post author

3. **`sendMessageNotification`** - Chat notifications (onCreate `messages/{conversationId}/messages/{messageId}`)

   - Aggregates notifications per conversation
   - Sends push notification to recipient

4. **`cleanupExpiredNotifications`** - Scheduled cleanup (daily 3am BRT)
   - Removes expired notifications

**Push Notifications Architecture:**

```dart
// Service (Singleton)
PushNotificationService()
  - initialize()              // Setup FCM handlers
  - requestPermission()        // Ask user for permission
  - saveTokenForProfile(id)   // Store FCM token in Firestore
  - switchProfile(old, new)   // Update tokens on profile change

// Provider (Riverpod)
pushNotificationProvider      // State + lifecycle management
lastReceivedMessageProvider   // Latest foreground message
lastTappedNotificationProvider // Latest tapped notification

// FCM Token Storage
profiles/{profileId}/fcmTokens/{token}
  - token: String
  - platform: 'ios' | 'android'
  - createdAt: Timestamp
  - lastUsedAt: Timestamp
```

**Setup Requirements:**

- **Android:** `POST_NOTIFICATIONS` permission in AndroidManifest
- **iOS:** Push Notifications capability + APNs key in Firebase Console
- **Cloud Functions:** Firebase Messaging API enabled

**Deploy:**

```bash
cd functions
npm install
firebase use to-sem-banda-83e19
firebase deploy --only functions
firebase functions:log                       # Monitor execution
firebase functions:log --only notifyNearbyPosts  # Filter specific function
```

**CRITICAL:**

- Use field name `notificationRadius` (not `notificationRadiusKm`)
- Call `FirebaseMessaging.onBackgroundMessage()` in main.dart BEFORE runApp()
- iOS setup requires manual Xcode configuration (see `ios/PUSH_NOTIFICATIONS_SETUP.md`)

**Files:**

- `functions/index.js` - Cloud Functions with FCM integration
- `packages/app/lib/features/notifications/data/services/push_notification_service.dart` - FCM service
- `packages/app/lib/features/notifications/presentation/providers/push_notification_provider.dart` - Riverpod provider
- `packages/app/lib/features/settings/presentation/pages/notification_settings_page.dart` - UI for user settings
- `docs/guides/PUSH_NOTIFICATIONS.md` - Complete setup guide

---

## 🛠️ Developer Workflows

**Initial Setup:**

```bash
melos bootstrap              # Install ALL monorepo dependencies (REQUIRED!)
cd ios && pod install        # iOS only
cd functions && npm install  # Cloud Functions
```

**Running:**

```bash
# From root or packages/app/
flutter run --flavor dev -t lib/main_dev.dart  # Dev (recommended)
flutter run  # Requires google-services.json, GoogleService-Info.plist, .env
```

**Building:**

```bash
# From packages/app/
flutter build ios --flavor prod -t lib/main_prod.dart --release
flutter build apk --flavor prod -t lib/main_prod.dart --release
flutter build appbundle --flavor prod -t lib/main_prod.dart --release

# Or use automated script
./scripts/build_release.sh prod
```

**Debugging:**

```bash
scripts/check_posts.sh              # Audit Firestore posts for missing fields
firebase functions:log              # Cloud Function execution logs
firebase functions:log --only notifyNearbyPosts  # Filter specific function
flutter clean && melos get          # Nuclear option for dependency issues
flutter run --verbose               # Detailed debug output
```

---

## 🐛 Common Issues & Solutions

| Issue                                          | Root Cause                               | Solution                                                                                     |
| ---------------------------------------------- | ---------------------------------------- | -------------------------------------------------------------------------------------------- |
| `Query requires index`                         | Missing composite index in Firestore     | `firebase deploy --only firestore:indexes`, wait for "Enabled" in console, then deploy rules |
| Profile state bugs                             | Cached `activeProfile` in local variable | ALWAYS use `ref.read(profileProvider).value?.activeProfile` (never cache)                    |
| Image upload freezing                          | Compression on main isolate              | Use `compute(_compressImageIsolate, path)` pattern (see `post_page.dart:442`)                |
| Hot reload not working after logout            | Riverpod state not cleared               | Use hot restart (⌘+Shift+\ on macOS) - hot reload insufficient for auth changes              |
| Cloud Functions not firing                     | Region mismatch or deploy failed         | Check `firebase functions:log --only notifyNearbyPosts`, verify `southamerica-east1` region  |
| `LateInitializationError` after profile switch | Provider not invalidated                 | Invalidate `postProvider`, `conversationProvider`, etc. See `main.dart` listener pattern     |
| Memory leaks in streams                        | StreamController not disposed            | Always add `ref.onDispose(() => _streamController.close())` in providers                     |
| Monorepo dependency issues                     | `melos bootstrap` not run                | Run `melos bootstrap` from root, then `melos get` to sync all packages                       |

---

## 📁 Key Reference Files

**State Management:**

- `packages/app/lib/main.dart` - Firebase init (3 retry attempts), error boundary, MarkerCache warmup, profile/auth listeners
- `packages/core_ui/lib/di/profile_providers.dart` - Global profile provider (AsyncNotifier with StreamController)
- `packages/app/lib/features/auth/presentation/providers/auth_providers.dart` - Auth state stream
- `packages/core_ui/lib/navigation/bottom_nav_scaffold.dart` - Lazy stream initialization, ValueNotifier navigation

**Clean Architecture:**

- `packages/core_ui/lib/{auth_result,profile_result,post_result,messages_result}.dart` - Sealed classes for type-safe results
- `packages/app/lib/features/profile/data/repositories/profile_repository_impl.dart` - Atomic transactions, ownership validation
- `packages/app/lib/features/profile/domain/usecases/*.dart` - Business logic (5-profile limit, validations, analytics)

**Features:**

- `packages/app/lib/features/home/presentation/pages/home_page.dart` - Geosearch, map, carousel, pagination
- `packages/app/lib/features/post/presentation/pages/post_page.dart` - Image compression isolate, post creation
- `packages/app/lib/features/messages/presentation/pages/messages_page.dart` - Chat list with unread counts
- `packages/app/lib/features/notifications/presentation/pages/notifications_page.dart` - Proximity + interest notifications

**Firebase:**

- `firestore.rules` - Profile-level security (uid ownership checks)
- `firestore.indexes.json` - 15 composite indexes (posts, notifications, conversations, interests)
- `functions/index.js` - Proximity notification Cloud Function (`notifyNearbyPosts`)

**Documentation:**

- `SESSION_10_CODE_QUALITY_OPTIMIZATION.md` - Performance patterns (debugPrint, CachedNetworkImage)
- `SESSION_14_MULTI_PROFILE_REFACTORING.md` - Clean Architecture migration (atomic transactions, sealed classes)
- `NEARBY_POST_NOTIFICATIONS.md` - Cloud Functions deployment guide
- `WIREFRAME.md` - UI/UX design system

**Design System:**

- `packages/core_ui/lib/theme/app_colors.dart` - Dual-purpose palette (Teal `#00A699` for musicians, Coral `#FF6B6B` for bands)
- `packages/core_ui/lib/theme/app_theme.dart` - Material 3 theme with custom typography (Airbnb 2025-inspired)
- Typography: Cereal font family (Regular 400, Medium 500, Bold 600, ExtraBold 700)
- Dark mode support via `.env` (`APP_THEME=dark`)
- See `docs/design/DESIGN_SYSTEM_REPORT.md` for comprehensive design tokens

**Critical Dependencies:**

- `cached_network_image: ^3.4.1` - MANDATORY for all remote images (80% perf boost vs Image.network)
- `flutter_image_compress: ^2.4.0` - Image compression in isolates (prevents UI freeze)
- `google_maps_flutter: ^2.14.0` - Map with custom markers
- `firebase_messaging: ^16.0.3` - Push notifications (FCM)
- `firebase_crashlytics: >=5.0.5 <6.0.0` - Error reporting (integrated in main.dart)
- `flutter_riverpod: ^3.0.3` - State management (AsyncNotifier pattern)
- `rxdart: ^0.28.0` - Stream combination (notifications_page.dart)
- `timeago: ^3.7.0` - Relative timestamps (`"5 min atrás"`, locale: `pt_BR`)
- `share_plus: ^12.0.1` - Native sharing (WhatsApp, social media)
- `flutter_linkify: ^6.0.0` - Auto-clickable URLs
- `uuid: ^4.3.3` - Generate unique IDs
- `hive_flutter: ^1.1.0` - Local storage (initialized once in main.dart)

---

## 📐 Conventions & Standards

**Naming:**

- Repositories: `ProfileRepository`, `PostRepository` (CRUD only)
- Services: `ProfileService`, `AuthService` (business logic)
- Providers: `profileProvider`, `authStateProvider` (Riverpod)
- Results: `ProfileResult`, `AuthResult` (sealed classes)
- Constants: UPPER_SNAKE_CASE (`MAX_PROFILES = 5`)

**Error Handling:**

- Use `debugPrint()` for all logging (stripped in release builds)
- ❌ NEVER use `print()` (persists in production, leaks sensitive data)
- Catch exceptions at service/repository level, never let them bubble to UI
- Show user-friendly messages via `ScaffoldMessenger.of(context).showSnackBar()`
- Log critical errors to Crashlytics via `FirebaseCrashlytics.instance.recordError()`
- Ignore non-fatal errors: Google Maps iOS channel errors (see `main.dart:70-76`)

**Code Organization:**

- `packages/core_ui/lib/core/` - Sealed classes (AuthResult, ProfileResult, PostResult, MessagesResult)
- `packages/core_ui/lib/models/` - Shared models (SearchParams)
- `packages/app/lib/features/*/data/repositories/` - Repository implementations (Firestore CRUD, atomic transactions)
- `packages/app/lib/features/*/domain/usecases/` - Business logic (validations, analytics)
- `packages/app/lib/features/*/presentation/providers/` - Riverpod AsyncNotifiers (feature state management)
- `packages/core_ui/lib/di/` - Global providers (profile, auth)
- `packages/app/lib/features/*/presentation/pages/` - Full-screen UI routes
- `packages/core_ui/lib/widgets/` - Reusable components (shared across features)
- `packages/core_ui/lib/theme/` - Design system (AppColors, AppTheme, AppTypography)
- `packages/core_ui/lib/utils/` - Helpers (Debouncer, Throttler, extensions)

**Provider Pattern (Riverpod 3.x):**

```dart
// AsyncNotifier for async state (posts, profiles, messages)
class PostNotifier extends AsyncNotifier<List<Post>> {
  @override
  FutureOr<List<Post>> build() async {
    // Always register dispose cleanup for streams/controllers
    ref.onDispose(() {
      // Cleanup resources here
    });
    return _loadPosts();
  }
}

final postProvider = AsyncNotifierProvider<PostNotifier, List<Post>>(PostNotifier.new);

// Notifier for sync state (push notifications)
class PushNotificationNotifier extends Notifier<PushNotificationState> {
  @override
  PushNotificationState build() => PushNotificationState.initial();
}

final pushNotificationProvider = NotifierProvider<PushNotificationNotifier, PushNotificationState>(
  PushNotificationNotifier.new,
);

// StreamProvider for real-time data (auth state)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// FutureProvider for one-time async data
final userProvider = FutureProvider.family<User?, String>((ref, userId) async {
  return FirebaseFirestore.instance.collection('users').doc(userId).get()
    .then((doc) => doc.exists ? User.fromMap(doc.data()!) : null);
});
```

**Testing:**

- Run `flutter test` (currently minimal coverage - widget_test.dart only)
- Manual testing via iOS Simulator and Android Emulator (primary QA method)
- Firestore data validation via `scripts/check_posts.sh`
- Cloud Functions testing: `firebase functions:log --only notifyNearbyPosts`

---

## 📊 Project Status

**Stable (production-ready):**

- ✅ Multi-profile architecture with atomic transactions
- ✅ Geosearch with 15 Firestore composite indexes
- ✅ Ephemeral posts (30-day expiry)
- ✅ Real-time chat with unread counts
- ✅ Proximity notifications (Cloud Functions `notifyNearbyPosts`)
- ✅ Interest notifications (Cloud Functions `sendInterestNotification`)
- ✅ Message notifications (Cloud Functions `sendMessageNotification`)
- ✅ Image compression (isolate-based, 85% quality)
- ✅ CachedNetworkImage everywhere (80% perf boost)
- ✅ Map marker cache (95% faster)
- ✅ ValueNotifier navigation (prevents unnecessary rebuilds)
- ✅ Lazy stream initialization (performance optimization)
- ✅ Push notifications (FCM + Cloud Functions integration)
- ✅ Badge counters (unread notifications/messages per profile)

**In Development:**

- 🚧 Deep links (planned)
- 🚧 Analytics dashboard (Firebase Analytics integrated but no UI yet)

---

## 🔒 Security & Backend Protection

### Firestore Security Rules

**Status:** ✅ **IMPLEMENTED** (comprehensive protection with data validation)

**What's Protected:**

```dart
// 1. Authentication Required for All Operations
allow read, write: if request.auth != null;

// 2. Users Collection - Self-access only
users/{userId}: read/write only if request.auth.uid == userId

// 3. Profiles - Owner verification + Data Validation
create: if request.resource.data.uid == request.auth.uid
  && name.size() >= 2 && name.size() <= 50
  && location is latlng
  && bio.size() <= 500
update/delete: same validations + owner check

// 4. Posts - Multi-profile ownership + Data Validation
create: authorUid == request.auth.uid
  && authorProfileId is owned by user
  && location is latlng
  && expiresAt > request.time
  && description.size() <= 1000
  && type in ['musician', 'band']
update/delete: same validations + author check

// 5. Conversations - Participant-based access
read/write: if request.auth.uid in resource.data.participants

// 6. Messages - SECURE: Only conversation participants
read: if auth.uid in parent conversation participants
create: if auth.uid in participants AND senderId == auth.uid
update/delete: if auth.uid == senderId

// 7. Notifications - Profile-isolated
read: authenticated users (client filters by recipientProfileId)
create: authenticated users can send to any profile

// 8. Rate Limits - Server-side only
rateLimits/{limitId}: allow read, write: if false (Admin SDK only)
```

**Validations Implemented:**

- ✅ **Field type validation** (string, latlng, timestamp, bool)
- ✅ **Field size validation** (name 2-50 chars, bio ≤500, description ≤1000)
- ✅ **Required fields** (uid, location, expiresAt, createdAt)
- ✅ **Enum validation** (type in ['musician', 'band'])
- ✅ **Temporal validation** (expiresAt > request.time)
- ✅ **Message access control** (participant verification via Firestore lookup)

**File:** `firestore.rules` (~180 lines)

---

### Firebase Storage Rules

**Status:** ✅ **IMPLEMENTED** (comprehensive file validation)

**What's Protected:**

```dart
// Helper functions
function isValidImageSize() {
  return request.resource.size < 10 * 1024 * 1024; // 10MB
}

function isValidImageType() {
  return request.resource.contentType.matches('image/.*');
}

// 1. User Photos - Self-access only + Validation
user_photos/{userId}/*:
  write: if auth.uid == userId AND size < 10MB AND MIME type image/*

// 2. Posts Photos - Authenticated + Validation
posts/*:
  write: if authenticated AND size < 10MB AND MIME type image/*

// 3. Profile Photos - Authenticated + Validation
profiles/{profileId}/*:
  write: if authenticated AND size < 10MB AND MIME type image/*

// 4. Public Files - Admin-only write
public/*: write only if request.auth.token.admin == true
```

**Protections Implemented:**

- ✅ **File size limit** (10MB max - prevents abuse/cost issues)
- ✅ **MIME type validation** (only image/\* allowed - blocks malicious files)
- ✅ **Authentication required** (all uploads need valid Firebase Auth token)
- ✅ **Ownership validation** (user_photos restricted to owner)

**Performance Impact:** Zero - validation happens server-side before upload completes

**File:** `storage.rules` (~50 lines)

---

### Cloud Functions Security

**Status:** ✅ **IMPLEMENTED** (rate limiting + spam protection)

**What's Protected:**

```javascript
// 1. Firestore Triggers (onCreate/onUpdate/onDelete)
// ✅ Cannot be called directly by clients (Firebase-managed)
// ✅ Automatic authentication via Firebase Admin SDK

exports.notifyNearbyPosts = functions.firestore
  .document("posts/{postId}")
  .onCreate(async (snap, context) => {
    // ✅ Rate limiting: 20 posts/day per user
    const rateLimitCheck = await checkRateLimit(
      authorUid,
      "posts",
      20,
      86400000
    );
    if (!rateLimitCheck.allowed) {
      console.log("🚫 Rate limit exceeded");
      return null; // Don't send notifications but allow post creation
    }
  });

// 2. Rate Limiting Implementation (Firestore-based counters)
async function checkRateLimit(userId, action, limit, windowMs) {
  // Counter with automatic reset after time window
  // Fail-open: allows requests if error occurs (no blocking)
  // Returns: { allowed: bool, remaining: number, resetAt: Date }
}

// 3. Rate Limits Applied:
// - Posts: 20/day per user
// - Interests: 50/day per profile
// - Messages: 500/day per profile

// 4. Data Validation Inside Functions
// ✅ Validates post.location, profile.location before processing
// ✅ Filters out invalid/missing data
```

**Rate Limiting Details:**

- ✅ **Posts:** 20 per day per user (prevents spam)
- ✅ **Interests:** 50 per day per profile (prevents bot abuse)
- ✅ **Messages:** 500 per day per profile (legitimate use allowed)
- ✅ **Fail-open design:** If rate limit check fails, allows request (no false positives blocking users)
- ✅ **Automatic reset:** Counters reset after 24h window
- ✅ **Zero impact on existing users:** Only triggers after limit exceeded

**Performance Impact:**

- ⚡ **1 extra Firestore read per function call** (cached for 24h)
- ⚡ **Async/non-blocking** - doesn't delay notifications
- ⚡ **Minimal latency** (<50ms overhead)

**Monitoring:**

```bash
firebase functions:log --only notifyNearbyPosts  # Check rate limit logs
firebase functions:log | grep "Rate limit"       # Filter rate limit events
```

**Files:** `functions/index.js` (~750 lines), `functions/README.md`

---

## 🔐 Frontend Security

### Environment Variables & API Keys

**Status:** ✅ **IMPLEMENTED** (secure key management)

**What's Protected:**

```dart
// EnvService - Centralized environment management
await EnvService.init();  // Load .env before Firebase.initializeApp()
final apiKey = EnvService.get('GOOGLE_MAPS_API_KEY');

// Automatic masking in logs (development only)
EnvService.printAll();  // Keys/tokens show as ****

// .gitignore protection
.env
*.env
!.env.example  // Template for developers
```

**File:** `packages/app/lib/config/env_service.dart`, `.env.example`

---

### Code Obfuscation

**Status:** ✅ **IMPLEMENTED** (ProGuard + Flutter obfuscation)

**Build Commands:**

```bash
# Automated script (recommended)
./scripts/build_release.sh

# Manual - Android
flutter build apk --release --obfuscate --split-debug-info=build/symbols/android

# Manual - iOS
flutter build ios --release --obfuscate --split-debug-info=build/symbols/ios
```

**ProGuard Configuration:**

```gradle
// android/app/build.gradle.kts
buildTypes {
  release {
    isMinifyEnabled = true
    isShrinkResources = true
    proguardFiles("proguard-android-optimize.txt", "proguard-rules.pro")
  }
}
```

**Protections:**

- ✅ **Code obfuscation** (class/method names scrambled)
- ✅ **Dead code elimination** (unused code removed)
- ✅ **Resource shrinking** (10-25% smaller APK)
- ✅ **Debug symbols separated** (Crashlytics compatible)

**Files:** `scripts/build_release.sh`, `android/app/proguard-rules.pro`

---

### Secure Local Storage

**Status:** ✅ **IMPLEMENTED** (Keychain/Keystore encryption)

**Usage:**

```dart
// ✅ SENSITIVE data: use SecureStorageService
await SecureStorageService.write('auth_token', token);
final token = await SecureStorageService.read('auth_token');

// ✅ NON-SENSITIVE cache: use CacheService (SharedPreferences)
await CacheService.cachePosts(posts);  // Offline posts
```

**Platform Security:**

- **iOS:** Keychain Services (`KeychainAccessibility.first_unlock`)
- **Android:** EncryptedSharedPreferences (Keystore-backed AES-256)

**Performance:**

- 10-50ms per operation (vs 1-5ms SharedPreferences)
- Negligible UX impact (low frequency operations)

**File:** `packages/app/lib/config/secure_storage_service.dart`

---

## 🔍 When to Reference External Docs

- **Multi-profile state bugs:** Read `SESSION_14_MULTI_PROFILE_REFACTORING.md` (atomic transactions, sealed classes)
- **Performance issues:** Read `SESSION_10_CODE_QUALITY_OPTIMIZATION.md` (debouncing, CachedNetworkImage, debugPrint)
- **Cloud Functions not working:** Read `NEARBY_POST_NOTIFICATIONS.md` (deployment, field names, `notifyNearbyPosts` function)
- **Firestore security:** Read `firestore.rules` (profile-level ownership model)
- **Index errors:** Check `firestore.indexes.json` (15 composite indexes with deployment order)
- **Badge counters:** Read `SESSION_15_BADGE_COUNTER_BEST_PRACTICES.md` (unread counts implementation)
- **Backend security:** Read `SECURITY_IMPLEMENTATION_2025-11-27.md` (comprehensive backend protection guide)
- **Frontend security:** Read `FRONTEND_SECURITY_IMPLEMENTATION_2025-11-27.md` (obfuscation, secure storage)
