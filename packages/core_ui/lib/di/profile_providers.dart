import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import 'package:core_ui/features/profile/domain/entities/profile_entity.dart';
import '../../features/profile/domain/usecases/create_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/domain/usecases/switch_active_profile.dart';
import '../../features/profile/domain/usecases/delete_profile.dart';
import '../../features/profile/domain/usecases/load_all_profiles.dart';
import '../../features/profile/domain/usecases/get_active_profile.dart';
import '../profile_result.dart';

/// ============================================
/// DATA LAYER - Dependency Injection
/// ============================================

/// Provider para ProfileRemoteDataSource (singleton)
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl();
});

/// Provider para ProfileRepository (singleton)
final profileRepositoryNewProvider = Provider<ProfileRepository>((ref) {
  final dataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource: dataSource);
});

/// ============================================
/// DOMAIN LAYER - UseCases
/// ============================================

final createProfileUseCaseProvider = Provider<CreateProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryNewProvider);
  return CreateProfileUseCase(repository);
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryNewProvider);
  return UpdateProfileUseCase(repository);
});

final switchActiveProfileUseCaseProvider = Provider<SwitchActiveProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryNewProvider);
  return SwitchActiveProfileUseCase(repository);
});

final deleteProfileUseCaseProvider = Provider<DeleteProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryNewProvider);
  return DeleteProfileUseCase(repository);
});

final loadAllProfilesUseCaseProvider = Provider<LoadAllProfilesUseCase>((ref) {
  final repository = ref.watch(profileRepositoryNewProvider);
  return LoadAllProfilesUseCase(repository);
});

final getActiveProfileUseCaseProvider = Provider<GetActiveProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryNewProvider);
  return GetActiveProfileUseCase(repository);
});

/// ============================================
/// PRESENTATION LAYER - State Management
/// ============================================

/// State do perfil (migrado para ProfileEntity)
class ProfileState {
  final ProfileEntity? activeProfile;
  final List<ProfileEntity> profiles;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.activeProfile,
    this.profiles = const [],
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    ProfileEntity? activeProfile,
    List<ProfileEntity>? profiles,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      activeProfile: activeProfile ?? this.activeProfile,
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// ProfileNotifier - Gerencia estado global de perfis
class ProfileNotifier extends AsyncNotifier<ProfileState> {
  /// Stream para observar mudanças no perfil ativo
  Stream<ProfileState> get stream => _streamController.stream;

  final StreamController<ProfileState> _streamController = StreamController.broadcast();

  @override
  set state(AsyncValue<ProfileState> value) {
    super.state = value;
    if (value is AsyncData<ProfileState>) {
      _streamController.add(value.value);
    }
  }

  @override
  FutureOr<ProfileState> build() async {
    // Registra dispose para cleanup
    ref.onDispose(() {
      _streamController.close();
    });

    return _loadProfiles();
  }

  Future<ProfileState> _loadProfiles() async {
    try {
      debugPrint('🔄 ProfileNotifier: Carregando perfis...');
      
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        debugPrint('⚠️ ProfileNotifier: Usuário não autenticado');
        return ProfileState(isLoading: false);
      }

      final loadAllProfiles = ref.read(loadAllProfilesUseCaseProvider);
      final getActiveProfile = ref.read(getActiveProfileUseCaseProvider);

      final List<ProfileEntity> profiles = await loadAllProfiles(uid);
      final ProfileEntity? activeProfile = await getActiveProfile(uid);

      debugPrint('✅ ProfileNotifier: ${profiles.length} perfis carregados, ativo: ${activeProfile?.name ?? "nenhum"}');

      return ProfileState(
        activeProfile: activeProfile,
        profiles: profiles,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ProfileNotifier: Erro ao carregar - $e');
      debugPrint(stackTrace.toString());
      return ProfileState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> switchProfile(String profileId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      final switchUseCase = ref.read(switchActiveProfileUseCaseProvider);
      await switchUseCase(uid, profileId);

      state = AsyncValue.data(await _loadProfiles());
    } catch (e) {
      debugPrint('❌ ProfileNotifier: Erro ao trocar perfil - $e');
      rethrow;
    }
  }

  Future<ProfileResult> createProfile(ProfileEntity profile) async {
    try {
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return const ProfileFailure(message: 'Usuário não autenticado');
      }

      final CreateProfileUseCase createUseCase = ref.read(createProfileUseCaseProvider);
      await createUseCase(profile, uid);

      state = AsyncValue.data(await _loadProfiles());
      return ProfileSuccess(profile: profile);
    } catch (e) {
      debugPrint('❌ ProfileNotifier: Erro ao criar perfil - $e');
      return ProfileFailure(
        message: 'Erro ao criar perfil: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  Future<ProfileResult> updateProfile(ProfileEntity profile) async {
    try {
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return const ProfileFailure(message: 'Usuário não autenticado');
      }

      final UpdateProfileUseCase updateUseCase = ref.read(updateProfileUseCaseProvider);
      await updateUseCase(profile, uid);

      state = AsyncValue.data(await _loadProfiles());
      return ProfileSuccess(profile: profile);
    } catch (e) {
      debugPrint('❌ ProfileNotifier: Erro ao atualizar perfil - $e');
      return ProfileFailure(
        message: 'Erro ao atualizar perfil: ${e.toString()}',
        exception: e is Exception ? e : null,
      );
    }
  }

  Future<void> deleteProfile(String profileId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      final deleteUseCase = ref.read(deleteProfileUseCaseProvider);
      await deleteUseCase(profileId, uid);

      state = AsyncValue.data(await _loadProfiles());
    } catch (e) {
      debugPrint('❌ ProfileNotifier: Erro ao deletar perfil - $e');
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = AsyncValue.data(await _loadProfiles());
  }
}

/// ============================================
/// GLOBAL PROVIDERS - Mantidos para compatibilidade
/// ============================================

/// Provider principal do Profile (AsyncNotifier)
final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);

/// Provider para perfil ativo atual (null-safe)
final activeProfileProvider = Provider<ProfileEntity?>((ref) {
  final AsyncValue<ProfileState> profileState = ref.watch(profileProvider);
  return profileState.maybeWhen(
    data: (ProfileState state) => state.activeProfile,
    orElse: () => null,
  );
});

/// Provider para lista de perfis
final profileListProvider = Provider<List<ProfileEntity>>((ref) {
  final AsyncValue<ProfileState> profileState = ref.watch(profileProvider);
  return profileState.maybeWhen(
    data: (ProfileState state) => state.profiles,
    orElse: () => <ProfileEntity>[],
  );
});

/// Provider para verificar se tem múltiplos perfis
final hasMultipleProfilesProvider = Provider<bool>((ref) {
  final profiles = ref.watch(profileListProvider);
  return profiles.length > 1;
});

/// Provider para stream de mudanças de perfil
final profileStreamProvider = StreamProvider<ProfileState>((ref) {
  final notifier = ref.watch(profileProvider.notifier);
  return notifier.stream;
});
