// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider para Firestore instance

@ProviderFor(firestore)
const firestoreProvider = FirestoreProvider._();

/// Provider para Firestore instance

final class FirestoreProvider extends $FunctionalProvider<FirebaseFirestore,
    FirebaseFirestore, FirebaseFirestore> with $Provider<FirebaseFirestore> {
  /// Provider para Firestore instance
  const FirestoreProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'firestoreProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$firestoreHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firestore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firestoreHash() => r'0e25e335c5657f593fc1baf3d9fd026e70bca7fa';

/// Provider para HomeRepository

@ProviderFor(homeRepository)
const homeRepositoryProvider = HomeRepositoryProvider._();

/// Provider para HomeRepository

final class HomeRepositoryProvider
    extends $FunctionalProvider<HomeRepository, HomeRepository, HomeRepository>
    with $Provider<HomeRepository> {
  /// Provider para HomeRepository
  const HomeRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'homeRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$homeRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeRepository create(Ref ref) {
    return homeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeRepository>(value),
    );
  }
}

String _$homeRepositoryHash() => r'acfd1b6a39851f5dbf8a8776cc45abb2a32c8b64';

/// Provider para LoadNearbyPostsUseCase

@ProviderFor(loadNearbyPostsUseCase)
const loadNearbyPostsUseCaseProvider = LoadNearbyPostsUseCaseProvider._();

/// Provider para LoadNearbyPostsUseCase

final class LoadNearbyPostsUseCaseProvider extends $FunctionalProvider<
    LoadNearbyPostsUseCase,
    LoadNearbyPostsUseCase,
    LoadNearbyPostsUseCase> with $Provider<LoadNearbyPostsUseCase> {
  /// Provider para LoadNearbyPostsUseCase
  const LoadNearbyPostsUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'loadNearbyPostsUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$loadNearbyPostsUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadNearbyPostsUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadNearbyPostsUseCase create(Ref ref) {
    return loadNearbyPostsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadNearbyPostsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadNearbyPostsUseCase>(value),
    );
  }
}

String _$loadNearbyPostsUseCaseHash() =>
    r'9fa666579f1733c299742ef279970afb6cd0fee1';

/// Provider para LoadPostsByGenresUseCase

@ProviderFor(loadPostsByGenresUseCase)
const loadPostsByGenresUseCaseProvider = LoadPostsByGenresUseCaseProvider._();

/// Provider para LoadPostsByGenresUseCase

final class LoadPostsByGenresUseCaseProvider extends $FunctionalProvider<
    LoadPostsByGenresUseCase,
    LoadPostsByGenresUseCase,
    LoadPostsByGenresUseCase> with $Provider<LoadPostsByGenresUseCase> {
  /// Provider para LoadPostsByGenresUseCase
  const LoadPostsByGenresUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'loadPostsByGenresUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$loadPostsByGenresUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadPostsByGenresUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadPostsByGenresUseCase create(Ref ref) {
    return loadPostsByGenresUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadPostsByGenresUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadPostsByGenresUseCase>(value),
    );
  }
}

String _$loadPostsByGenresUseCaseHash() =>
    r'e8b6dd465a6e3e1603268068e62d3e1f1f5da71b';

/// Provider para SearchProfilesUseCase

@ProviderFor(searchProfilesUseCase)
const searchProfilesUseCaseProvider = SearchProfilesUseCaseProvider._();

/// Provider para SearchProfilesUseCase

final class SearchProfilesUseCaseProvider extends $FunctionalProvider<
    SearchProfilesUseCase,
    SearchProfilesUseCase,
    SearchProfilesUseCase> with $Provider<SearchProfilesUseCase> {
  /// Provider para SearchProfilesUseCase
  const SearchProfilesUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchProfilesUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchProfilesUseCaseHash();

  @$internal
  @override
  $ProviderElement<SearchProfilesUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SearchProfilesUseCase create(Ref ref) {
    return searchProfilesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchProfilesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchProfilesUseCase>(value),
    );
  }
}

String _$searchProfilesUseCaseHash() =>
    r'a8911d5395c1dc73af420d36cf214388745e67be';

/// Notifier para gerenciar feed de posts

@ProviderFor(FeedNotifier)
const feedProvider = FeedNotifierProvider._();

/// Notifier para gerenciar feed de posts
final class FeedNotifierProvider
    extends $NotifierProvider<FeedNotifier, FeedState> {
  /// Notifier para gerenciar feed de posts
  const FeedNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'feedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$feedNotifierHash();

  @$internal
  @override
  FeedNotifier create() => FeedNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedState>(value),
    );
  }
}

String _$feedNotifierHash() => r'22815cc7b7bf72f9888a0df4655222fcde6ab7ff';

/// Notifier para gerenciar feed de posts

abstract class _$FeedNotifier extends $Notifier<FeedState> {
  FeedState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<FeedState, FeedState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FeedState, FeedState>, FeedState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

/// Notifier para busca de perfis

@ProviderFor(ProfileSearchNotifier)
const profileSearchProvider = ProfileSearchNotifierProvider._();

/// Notifier para busca de perfis
final class ProfileSearchNotifierProvider
    extends $NotifierProvider<ProfileSearchNotifier, ProfileSearchState> {
  /// Notifier para busca de perfis
  const ProfileSearchNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'profileSearchProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$profileSearchNotifierHash();

  @$internal
  @override
  ProfileSearchNotifier create() => ProfileSearchNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileSearchState>(value),
    );
  }
}

String _$profileSearchNotifierHash() =>
    r'4f2b8672b4088fc9ea47fee6a150b9db886e5e06';

/// Notifier para busca de perfis

abstract class _$ProfileSearchNotifier extends $Notifier<ProfileSearchState> {
  ProfileSearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ProfileSearchState, ProfileSearchState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ProfileSearchState, ProfileSearchState>,
        ProfileSearchState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Provider para stream de posts próximos (tempo real)

@ProviderFor(nearbyPostsStream)
const nearbyPostsStreamProvider = NearbyPostsStreamFamily._();

/// Provider para stream de posts próximos (tempo real)

final class NearbyPostsStreamProvider extends $FunctionalProvider<
        AsyncValue<List<PostEntity>>,
        List<PostEntity>,
        Stream<List<PostEntity>>>
    with $FutureModifier<List<PostEntity>>, $StreamProvider<List<PostEntity>> {
  /// Provider para stream de posts próximos (tempo real)
  const NearbyPostsStreamProvider._(
      {required NearbyPostsStreamFamily super.from,
      required Map<String, double> super.argument})
      : super(
          retry: null,
          name: r'nearbyPostsStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$nearbyPostsStreamHash();

  @override
  String toString() {
    return r'nearbyPostsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PostEntity>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<PostEntity>> create(Ref ref) {
    final argument = this.argument as Map<String, double>;
    return nearbyPostsStream(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyPostsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nearbyPostsStreamHash() => r'692aea45931febb23eb8bb0cc2fcf73f3ac9a654';

/// Provider para stream de posts próximos (tempo real)

final class NearbyPostsStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<Stream<List<PostEntity>>,
            Map<String, double>> {
  const NearbyPostsStreamFamily._()
      : super(
          retry: null,
          name: r'nearbyPostsStreamProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider para stream de posts próximos (tempo real)

  NearbyPostsStreamProvider call(
    Map<String, double> params,
  ) =>
      NearbyPostsStreamProvider._(argument: params, from: this);

  @override
  String toString() => r'nearbyPostsStreamProvider';
}
