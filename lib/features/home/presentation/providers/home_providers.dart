import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/load_nearby_posts.dart';
import '../../domain/usecases/load_posts_by_genres.dart';
import '../../domain/usecases/search_profiles.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../../post/domain/entities/post_entity.dart';
import '../../../post/presentation/providers/post_providers.dart';
import '../../../profile/domain/entities/profile_entity.dart';

// ========================= DATA LAYER =========================

/// Provider para Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider para HomeRepository
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final postRepository = ref.watch(postRepositoryNewProvider);
  final firestore = ref.watch(firestoreProvider);
  
  return HomeRepositoryImpl(
    postRepository: postRepository,
    firestore: firestore,
  );
});

// ========================= USE CASES =========================

/// Provider para LoadNearbyPostsUseCase
final loadNearbyPostsUseCaseProvider = Provider<LoadNearbyPostsUseCase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return LoadNearbyPostsUseCase(repository);
});

/// Provider para LoadPostsByGenresUseCase
final loadPostsByGenresUseCaseProvider = Provider<LoadPostsByGenresUseCase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return LoadPostsByGenresUseCase(repository);
});

/// Provider para SearchProfilesUseCase
final searchProfilesUseCaseProvider = Provider<SearchProfilesUseCase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return SearchProfilesUseCase(repository);
});

// ========================= PRESENTATION LAYER =========================

/// Estado do feed de posts
class FeedState {
  final List<PostEntity> posts;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final String? lastPostId;
  
  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.lastPostId,
  });
  
  FeedState copyWith({
    List<PostEntity>? posts,
    bool? isLoading,
    String? error,
    bool? hasMore,
    String? lastPostId,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      lastPostId: lastPostId ?? this.lastPostId,
    );
  }
}

/// Notifier para gerenciar feed de posts
class FeedNotifier extends Notifier<FeedState> {
  late final LoadNearbyPostsUseCase _loadNearbyPostsUseCase;
  late final LoadPostsByGenresUseCase _loadPostsByGenresUseCase;
  
  @override
  FeedState build() {
    _loadNearbyPostsUseCase = ref.watch(loadNearbyPostsUseCaseProvider);
    _loadPostsByGenresUseCase = ref.watch(loadPostsByGenresUseCaseProvider);
    return const FeedState();
  }
  
  /// Carrega posts próximos
  Future<void> loadNearbyPosts({
    required double latitude,
    required double longitude,
    required double radiusKm,
    bool refresh = false,
  }) async {
    if (state.isLoading) return;
    
    state = state.copyWith(
      isLoading: true,
      error: null,
      posts: refresh ? [] : state.posts,
      lastPostId: refresh ? null : state.lastPostId,
    );
    
    try {
      final posts = await _loadNearbyPostsUseCase(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        limit: 50,
        lastPostId: refresh ? null : state.lastPostId,
      );
      
      state = state.copyWith(
        posts: refresh ? posts : [...state.posts, ...posts],
        isLoading: false,
        hasMore: posts.length >= 50,
        lastPostId: posts.isNotEmpty ? posts.last.id : state.lastPostId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Carrega posts filtrados por gênero
  Future<void> loadPostsByGenres({
    required List<String> genres,
    required double latitude,
    required double longitude,
    required double radiusKm,
    bool refresh = false,
  }) async {
    if (state.isLoading) return;
    
    state = state.copyWith(
      isLoading: true,
      error: null,
      posts: refresh ? [] : state.posts,
      lastPostId: refresh ? null : state.lastPostId,
    );
    
    try {
      final posts = await _loadPostsByGenresUseCase(
        genres: genres,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        limit: 50,
        lastPostId: refresh ? null : state.lastPostId,
      );
      
      state = state.copyWith(
        posts: refresh ? posts : [...state.posts, ...posts],
        isLoading: false,
        hasMore: posts.length >= 50,
        lastPostId: posts.isNotEmpty ? posts.last.id : state.lastPostId,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Limpa o feed
  void clear() {
    state = const FeedState();
  }
}

/// Provider para FeedNotifier
final feedProvider = NotifierProvider<FeedNotifier, FeedState>(FeedNotifier.new);

// ========================= SEARCH =========================

/// Estado da busca de perfis
class ProfileSearchState {
  final List<Profile> profiles;
  final bool isLoading;
  final String? error;
  
  const ProfileSearchState({
    this.profiles = const [],
    this.isLoading = false,
    this.error,
  });
  
  ProfileSearchState copyWith({
    List<Profile>? profiles,
    bool? isLoading,
    String? error,
  }) {
    return ProfileSearchState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier para busca de perfis
class ProfileSearchNotifier extends Notifier<ProfileSearchState> {
  late final SearchProfilesUseCase _searchProfilesUseCase;
  
  @override
  ProfileSearchState build() {
    _searchProfilesUseCase = ref.watch(searchProfilesUseCaseProvider);
    return const ProfileSearchState();
  }
  
  /// Executa busca de perfis
  Future<void> searchProfiles({
    String? name,
    String? instrument,
    String? city,
  }) async {
    if (state.isLoading) return;
    
    state = state.copyWith(
      isLoading: true,
      error: null,
    );
    
    try {
      final profiles = await _searchProfilesUseCase(
        name: name,
        instrument: instrument,
        city: city,
        limit: 20,
      );
      
      state = state.copyWith(
        profiles: profiles,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Limpa resultados de busca
  void clear() {
    state = const ProfileSearchState();
  }
}

/// Provider para ProfileSearchNotifier
final profileSearchProvider = NotifierProvider<ProfileSearchNotifier, ProfileSearchState>(ProfileSearchNotifier.new);

// ========================= STREAMS =========================

/// Provider para stream de posts próximos (tempo real)
final nearbyPostsStreamProvider = StreamProvider.family<List<PostEntity>, Map<String, double>>((ref, params) {
  final repository = ref.watch(homeRepositoryProvider);
  
  final latitude = params['latitude'] ?? 0.0;
  final longitude = params['longitude'] ?? 0.0;
  final radiusKm = params['radiusKm'] ?? 50.0;
  
  return repository.watchNearbyPosts(
    latitude: latitude,
    longitude: longitude,
    radiusKm: radiusKm,
  );
});
