import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/datasources/post_remote_datasource.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/create_post.dart';
import '../../domain/usecases/update_post.dart';
import '../../domain/usecases/delete_post.dart';
import '../../domain/usecases/toggle_interest.dart';
import '../../domain/usecases/load_interested_users.dart';
import '../../../../models/post.dart' as legacy;
import '../../../../core/post_result.dart';

/// ============================================
/// DATA LAYER - Dependency Injection
/// ============================================

/// Provider para PostRemoteDataSource (singleton)
final postRemoteDataSourceProvider = Provider<IPostRemoteDataSource>((ref) {
  return PostRemoteDataSource();
});

/// Provider para PostRepository (singleton)
final postRepositoryNewProvider = Provider<PostRepository>((ref) {
  final dataSource = ref.read(postRemoteDataSourceProvider);
  return PostRepositoryImpl(remoteDataSource: dataSource);
});

/// ============================================
/// USE CASE LAYER - Dependency Injection
/// ============================================

final createPostUseCaseProvider = Provider<CreatePost>((ref) {
  final repository = ref.read(postRepositoryNewProvider);
  return CreatePost(repository);
});

final updatePostUseCaseProvider = Provider<UpdatePost>((ref) {
  final repository = ref.read(postRepositoryNewProvider);
  return UpdatePost(repository);
});

final deletePostUseCaseProvider = Provider<DeletePost>((ref) {
  final repository = ref.read(postRepositoryNewProvider);
  return DeletePost(repository);
});

final toggleInterestUseCaseProvider = Provider<ToggleInterest>((ref) {
  final repository = ref.read(postRepositoryNewProvider);
  return ToggleInterest(repository);
});

final loadInterestedUsersUseCaseProvider = Provider<LoadInterestedUsers>((ref) {
  final repository = ref.read(postRepositoryNewProvider);
  return LoadInterestedUsers(repository);
});

/// ============================================
/// STATE MANAGEMENT - PostNotifier
/// ============================================

/// State para PostNotifier
class PostState {
  final List<legacy.Post> posts;
  final bool isLoading;
  final String? error;

  const PostState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  PostState copyWith({
    List<legacy.Post>? posts,
    bool? isLoading,
    String? error,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// PostNotifier - Manages post state with Clean Architecture
class PostNotifier extends AsyncNotifier<PostState> {
  @override
  FutureOr<PostState> build() async {
    return PostState(posts: await _loadPosts());
  }

  Future<List<legacy.Post>> _loadPosts() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return [];

      final repository = ref.read(postRepositoryNewProvider);
      final entities = await repository.getAllPosts(uid);
      
      return entities.map(_entityToLegacy).toList();
    } catch (e) {
      debugPrint('❌ PostNotifier: Erro ao carregar posts - $e');
      return [];
    }
  }

  Future<PostResult> createPost(legacy.Post post) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return const PostFailure(message: 'Usuário não autenticado');
      }

      final createUseCase = ref.read(createPostUseCaseProvider);
      final entity = _legacyToEntity(post);
      await createUseCase(entity);

      // Refresh state
      state = AsyncValue.data(PostState(posts: await _loadPosts()));
      return PostSuccess(post: post);
    } catch (e) {
      debugPrint('❌ PostNotifier: Erro ao criar post - $e');
      return PostFailure(
        message: 'Erro ao criar post: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  Future<PostResult> updatePost(legacy.Post post) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return const PostFailure(message: 'Usuário não autenticado');
      }

      final updateUseCase = ref.read(updatePostUseCaseProvider);
      final entity = _legacyToEntity(post);
      await updateUseCase(entity, post.authorProfileId);

      // Refresh state
      state = AsyncValue.data(PostState(posts: await _loadPosts()));
      return PostSuccess(post: post);
    } catch (e) {
      debugPrint('❌ PostNotifier: Erro ao atualizar post - $e');
      return PostFailure(
        message: 'Erro ao atualizar post: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  Future<PostResult> deletePost(String postId, String profileId) async {
    try {
      final deleteUseCase = ref.read(deletePostUseCaseProvider);
      await deleteUseCase(postId, profileId);

      // Refresh state
      state = AsyncValue.data(PostState(posts: await _loadPosts()));
      
      // Return success with dummy post (just need the id)
      return PostSuccess(
        post: legacy.Post(
          id: postId,
          authorProfileId: profileId,
          authorUid: '',
          content: '',
          createdAt: DateTime.now(),
          type: 'musician',
          city: '',
          level: '',
          instruments: [],
          genres: [],
          seekingMusicians: [],
        ),
        message: 'Post deletado com sucesso',
      );
    } catch (e) {
      debugPrint('❌ PostNotifier: Erro ao deletar post - $e');
      return PostFailure(
        message: 'Erro ao deletar post: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  Future<PostResult> toggleInterest(String postId, String profileId) async {
    try {
      final toggleUseCase = ref.read(toggleInterestUseCaseProvider);
      final hasInterest = await toggleUseCase(postId, profileId);

      return InterestToggleSuccess(hasInterest);
    } catch (e) {
      debugPrint('❌ PostNotifier: Erro ao toggle interest - $e');
      return PostFailure(
        message: 'Erro ao demonstrar interesse: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  Future<List<String>> getInterestedUsers(String postId) async {
    try {
      final loadUseCase = ref.read(loadInterestedUsersUseCaseProvider);
      return await loadUseCase(postId);
    } catch (e) {
      debugPrint('❌ PostNotifier: Erro ao carregar interested users - $e');
      return [];
    }
  }

  Future<void> refresh() async {
    state = AsyncValue.data(PostState(posts: await _loadPosts()));
  }

  /// Conversão PostEntity -> Post (legacy)
  legacy.Post _entityToLegacy(PostEntity entity) {
    return legacy.Post(
      id: entity.id,
      authorProfileId: entity.authorProfileId,
      authorUid: entity.authorUid,
      content: entity.content,
      createdAt: entity.createdAt,
      type: entity.type,
      location: LatLng(entity.location.latitude, entity.location.longitude),
      city: entity.city,
      neighborhood: entity.neighborhood,
      state: entity.state,
      photoUrl: entity.photoUrl,
      youtubeLink: entity.youtubeLink,
      level: entity.level,
      instruments: entity.instruments,
      genres: entity.genres,
      seekingMusicians: entity.seekingMusicians,
      availableFor: entity.availableFor,
      distanceKm: entity.distanceKm,
    );
  }

  /// Conversão Post (legacy) -> PostEntity
  PostEntity _legacyToEntity(legacy.Post post) {
    return PostEntity(
      id: post.id,
      authorProfileId: post.authorProfileId,
      authorUid: post.authorUid,
      content: post.content,
      location: post.location != null
          ? GeoPoint(post.location!.latitude, post.location!.longitude)
          : const GeoPoint(0, 0),
      city: post.city,
      neighborhood: post.neighborhood,
      state: post.state,
      photoUrl: post.photoUrl,
      youtubeLink: post.youtubeLink,
      type: post.type,
      level: post.level,
      instruments: post.instruments,
      genres: post.genres,
      seekingMusicians: post.seekingMusicians,
      availableFor: post.availableFor,
      createdAt: post.createdAt,
      expiresAt: post.createdAt.add(const Duration(days: 30)),
      distanceKm: post.distanceKm,
    );
  }
}

/// ============================================
/// GLOBAL PROVIDERS (backward compatibility)
/// ============================================

/// Main post provider (backward compatible)
final postProvider = AsyncNotifierProvider<PostNotifier, PostState>(
  PostNotifier.new,
);

/// Helper provider to get just the posts list (backward compatible)
final postListProvider = Provider<List<legacy.Post>>((ref) {
  final postState = ref.watch(postProvider);
  return postState.when(
    data: (state) => state.posts,
    loading: () => [],
    error: (_, __) => [],
  );
});
