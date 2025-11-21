import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../repositories/profile_repository.dart';

class ProfileState {
  final Profile? activeProfile;
  final List<Profile> profiles;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.activeProfile,
    this.profiles = const [],
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    Profile? activeProfile,
    List<Profile>? profiles,
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

class ProfileNotifier extends AsyncNotifier<ProfileState> {
  late final IProfileRepository _repo;

  @override
  FutureOr<ProfileState> build() async {
    _repo = ref.read(profileRepositoryProvider);
    return _loadProfiles();
  }

  Future<ProfileState> _loadProfiles() async {
    try {
      final profiles = await _repo.getAllProfiles();
      final active = await _repo.getActiveProfile();
      return ProfileState(
        activeProfile: active,
        profiles: profiles,
        isLoading: false,
      );
    } catch (e) {
      return ProfileState(isLoading: false, error: e.toString());
    }
  }

  Future<void> switchProfile(String profileId) async {
    await _repo.switchActiveProfile(profileId);
    state = AsyncValue.data(await _loadProfiles());
  }

  Future<void> refresh() async {
    state = AsyncValue.data(await _loadProfiles());
  }
}

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
