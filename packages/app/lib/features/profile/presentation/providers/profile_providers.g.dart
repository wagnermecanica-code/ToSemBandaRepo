// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRemoteDataSourceHash() =>
    r'f1abd6607c606939e3a5f9dafd53e7ae8de41419';

/// ============================================
/// DATA LAYER - Dependency Injection
/// ============================================
/// Provider para ProfileRemoteDataSource (singleton)
///
/// Copied from [profileRemoteDataSource].
@ProviderFor(profileRemoteDataSource)
final profileRemoteDataSourceProvider =
    AutoDisposeProvider<ProfileRemoteDataSource>.internal(
  profileRemoteDataSource,
  name: r'profileRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRemoteDataSourceRef
    = AutoDisposeProviderRef<ProfileRemoteDataSource>;
String _$profileRepositoryNewHash() =>
    r'b585f2c7f37ca445c0255d375ae375342f9dbd93';

/// Provider para ProfileRepository (singleton)
///
/// Copied from [profileRepositoryNew].
@ProviderFor(profileRepositoryNew)
final profileRepositoryNewProvider =
    AutoDisposeProvider<ProfileRepository>.internal(
  profileRepositoryNew,
  name: r'profileRepositoryNewProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileRepositoryNewHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRepositoryNewRef = AutoDisposeProviderRef<ProfileRepository>;
String _$createProfileUseCaseHash() =>
    r'3104bd8a055cbbe28496ee89afa9cfc64f28f7e4';

/// ============================================
/// DOMAIN LAYER - UseCases
/// ============================================
///
/// Copied from [createProfileUseCase].
@ProviderFor(createProfileUseCase)
final createProfileUseCaseProvider =
    AutoDisposeProvider<CreateProfileUseCase>.internal(
  createProfileUseCase,
  name: r'createProfileUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createProfileUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CreateProfileUseCaseRef = AutoDisposeProviderRef<CreateProfileUseCase>;
String _$updateProfileUseCaseHash() =>
    r'935e2841094c237656457ed8670949c9cb2865ee';

/// See also [updateProfileUseCase].
@ProviderFor(updateProfileUseCase)
final updateProfileUseCaseProvider =
    AutoDisposeProvider<UpdateProfileUseCase>.internal(
  updateProfileUseCase,
  name: r'updateProfileUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateProfileUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpdateProfileUseCaseRef = AutoDisposeProviderRef<UpdateProfileUseCase>;
String _$switchActiveProfileUseCaseHash() =>
    r'ccf8bbfe30125f5abd8077ad20a11198684dfabe';

/// See also [switchActiveProfileUseCase].
@ProviderFor(switchActiveProfileUseCase)
final switchActiveProfileUseCaseProvider =
    AutoDisposeProvider<SwitchActiveProfileUseCase>.internal(
  switchActiveProfileUseCase,
  name: r'switchActiveProfileUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$switchActiveProfileUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SwitchActiveProfileUseCaseRef
    = AutoDisposeProviderRef<SwitchActiveProfileUseCase>;
String _$deleteProfileUseCaseHash() =>
    r'634dbfb14133227240a68ae934c1c159a11fd802';

/// See also [deleteProfileUseCase].
@ProviderFor(deleteProfileUseCase)
final deleteProfileUseCaseProvider =
    AutoDisposeProvider<DeleteProfileUseCase>.internal(
  deleteProfileUseCase,
  name: r'deleteProfileUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteProfileUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteProfileUseCaseRef = AutoDisposeProviderRef<DeleteProfileUseCase>;
String _$loadAllProfilesUseCaseHash() =>
    r'16a0a839b22827dec43db4fcdbe0e4e38ccde9b7';

/// See also [loadAllProfilesUseCase].
@ProviderFor(loadAllProfilesUseCase)
final loadAllProfilesUseCaseProvider =
    AutoDisposeProvider<LoadAllProfilesUseCase>.internal(
  loadAllProfilesUseCase,
  name: r'loadAllProfilesUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loadAllProfilesUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoadAllProfilesUseCaseRef
    = AutoDisposeProviderRef<LoadAllProfilesUseCase>;
String _$getActiveProfileUseCaseHash() =>
    r'ff0cd8cefe580986652728d9eb1fdbd1023ab032';

/// See also [getActiveProfileUseCase].
@ProviderFor(getActiveProfileUseCase)
final getActiveProfileUseCaseProvider =
    AutoDisposeProvider<GetActiveProfileUseCase>.internal(
  getActiveProfileUseCase,
  name: r'getActiveProfileUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getActiveProfileUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetActiveProfileUseCaseRef
    = AutoDisposeProviderRef<GetActiveProfileUseCase>;
String _$activeProfileHash() => r'fc32903c544b43733e9d3f4461b6cd74ff589c64';

/// ============================================
/// GLOBAL PROVIDERS - Mantidos para compatibilidade
/// ============================================
/// Provider para perfil ativo atual (null-safe)
///
/// Copied from [activeProfile].
@ProviderFor(activeProfile)
final activeProfileProvider = AutoDisposeProvider<ProfileEntity?>.internal(
  activeProfile,
  name: r'activeProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveProfileRef = AutoDisposeProviderRef<ProfileEntity?>;
String _$profileListHash() => r'a196080eb12c5133c03a19ecf282af1b946898b8';

/// Provider para lista de perfis
///
/// Copied from [profileList].
@ProviderFor(profileList)
final profileListProvider = AutoDisposeProvider<List<ProfileEntity>>.internal(
  profileList,
  name: r'profileListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$profileListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileListRef = AutoDisposeProviderRef<List<ProfileEntity>>;
String _$hasMultipleProfilesHash() =>
    r'd83b0a867e19223d0a76f70fe166d35267b279b6';

/// Provider para verificar se tem múltiplos perfis
///
/// Copied from [hasMultipleProfiles].
@ProviderFor(hasMultipleProfiles)
final hasMultipleProfilesProvider = AutoDisposeProvider<bool>.internal(
  hasMultipleProfiles,
  name: r'hasMultipleProfilesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasMultipleProfilesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasMultipleProfilesRef = AutoDisposeProviderRef<bool>;
String _$profileStreamHash() => r'a18f147c861dcdd53086b017b50481321c301581';

/// Provider para stream de mudanças de perfil
///
/// Copied from [profileStream].
@ProviderFor(profileStream)
final profileStreamProvider = AutoDisposeStreamProvider<ProfileState>.internal(
  profileStream,
  name: r'profileStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileStreamRef = AutoDisposeStreamProviderRef<ProfileState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
