// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ============================================
/// DATA LAYER - Dependency Injection
/// ============================================
/// Provider para PostRemoteDataSource (singleton)

@ProviderFor(postRemoteDataSource)
const postRemoteDataSourceProvider = PostRemoteDataSourceProvider._();

/// ============================================
/// DATA LAYER - Dependency Injection
/// ============================================
/// Provider para PostRemoteDataSource (singleton)

final class PostRemoteDataSourceProvider extends $FunctionalProvider<
    IPostRemoteDataSource,
    IPostRemoteDataSource,
    IPostRemoteDataSource> with $Provider<IPostRemoteDataSource> {
  /// ============================================
  /// DATA LAYER - Dependency Injection
  /// ============================================
  /// Provider para PostRemoteDataSource (singleton)
  const PostRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'postRemoteDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<IPostRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IPostRemoteDataSource create(Ref ref) {
    return postRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IPostRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IPostRemoteDataSource>(value),
    );
  }
}

String _$postRemoteDataSourceHash() =>
    r'928d5c5cea56c554b19ca2e20e88cf61c37d0d0c';

/// Provider para PostRepository (singleton)

@ProviderFor(postRepositoryNew)
const postRepositoryNewProvider = PostRepositoryNewProvider._();

/// Provider para PostRepository (singleton)

final class PostRepositoryNewProvider
    extends $FunctionalProvider<PostRepository, PostRepository, PostRepository>
    with $Provider<PostRepository> {
  /// Provider para PostRepository (singleton)
  const PostRepositoryNewProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'postRepositoryNewProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postRepositoryNewHash();

  @$internal
  @override
  $ProviderElement<PostRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PostRepository create(Ref ref) {
    return postRepositoryNew(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PostRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PostRepository>(value),
    );
  }
}

String _$postRepositoryNewHash() => r'd8afa23b143aeae8ba46f3153100092c6c6d2f82';

/// ============================================
/// USE CASE LAYER - Dependency Injection
/// ============================================

@ProviderFor(createPostUseCase)
const createPostUseCaseProvider = CreatePostUseCaseProvider._();

/// ============================================
/// USE CASE LAYER - Dependency Injection
/// ============================================

final class CreatePostUseCaseProvider
    extends $FunctionalProvider<CreatePost, CreatePost, CreatePost>
    with $Provider<CreatePost> {
  /// ============================================
  /// USE CASE LAYER - Dependency Injection
  /// ============================================
  const CreatePostUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'createPostUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$createPostUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreatePost> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreatePost create(Ref ref) {
    return createPostUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePost value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePost>(value),
    );
  }
}

String _$createPostUseCaseHash() => r'b4e427953d51e487cd57f96407be2a02e5656de6';

@ProviderFor(updatePostUseCase)
const updatePostUseCaseProvider = UpdatePostUseCaseProvider._();

final class UpdatePostUseCaseProvider
    extends $FunctionalProvider<UpdatePost, UpdatePost, UpdatePost>
    with $Provider<UpdatePost> {
  const UpdatePostUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updatePostUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updatePostUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdatePost> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdatePost create(Ref ref) {
    return updatePostUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdatePost value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdatePost>(value),
    );
  }
}

String _$updatePostUseCaseHash() => r'b9069157f83b697660a9cf6ab381ab4ab1cbb06e';

@ProviderFor(deletePostUseCase)
const deletePostUseCaseProvider = DeletePostUseCaseProvider._();

final class DeletePostUseCaseProvider
    extends $FunctionalProvider<DeletePost, DeletePost, DeletePost>
    with $Provider<DeletePost> {
  const DeletePostUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deletePostUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deletePostUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeletePost> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeletePost create(Ref ref) {
    return deletePostUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeletePost value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeletePost>(value),
    );
  }
}

String _$deletePostUseCaseHash() => r'335302287bae8da127f1e10d74be3eb59bb16092';

@ProviderFor(toggleInterestUseCase)
const toggleInterestUseCaseProvider = ToggleInterestUseCaseProvider._();

final class ToggleInterestUseCaseProvider
    extends $FunctionalProvider<ToggleInterest, ToggleInterest, ToggleInterest>
    with $Provider<ToggleInterest> {
  const ToggleInterestUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'toggleInterestUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$toggleInterestUseCaseHash();

  @$internal
  @override
  $ProviderElement<ToggleInterest> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ToggleInterest create(Ref ref) {
    return toggleInterestUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToggleInterest value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToggleInterest>(value),
    );
  }
}

String _$toggleInterestUseCaseHash() =>
    r'ee84d8a5ba0008913b1054ba3201161f399850e0';

@ProviderFor(loadInterestedUsersUseCase)
const loadInterestedUsersUseCaseProvider =
    LoadInterestedUsersUseCaseProvider._();

final class LoadInterestedUsersUseCaseProvider extends $FunctionalProvider<
    LoadInterestedUsers,
    LoadInterestedUsers,
    LoadInterestedUsers> with $Provider<LoadInterestedUsers> {
  const LoadInterestedUsersUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'loadInterestedUsersUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$loadInterestedUsersUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadInterestedUsers> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadInterestedUsers create(Ref ref) {
    return loadInterestedUsersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadInterestedUsers value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadInterestedUsers>(value),
    );
  }
}

String _$loadInterestedUsersUseCaseHash() =>
    r'4dc0abc44e9faf88da3f6c96c5309fe5c04dbb09';

/// Helper provider to get just the posts list

@ProviderFor(postList)
const postListProvider = PostListProvider._();

/// Helper provider to get just the posts list

final class PostListProvider extends $FunctionalProvider<List<PostEntity>,
    List<PostEntity>, List<PostEntity>> with $Provider<List<PostEntity>> {
  /// Helper provider to get just the posts list
  const PostListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'postListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postListHash();

  @$internal
  @override
  $ProviderElement<List<PostEntity>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<PostEntity> create(Ref ref) {
    return postList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PostEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PostEntity>>(value),
    );
  }
}

String _$postListHash() => r'777b238832ec4049e95074c6a578da2be6fcf92f';
