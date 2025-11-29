import 'package:core_ui/features/profile/domain/entities/profile_entity.dart';

/// Resultado type-safe para operações de perfil
sealed class ProfileResult {
  const ProfileResult();
}

/// Operação de perfil bem-sucedida
class ProfileSuccess extends ProfileResult {
  final ProfileEntity profile;
  final String? message;

  const ProfileSuccess({
    required this.profile,
    this.message,
  });
}

/// Lista de perfis carregada com sucesso
class ProfileListSuccess extends ProfileResult {
  final List<ProfileEntity> profiles;
  final ProfileEntity? activeProfile;

  const ProfileListSuccess({
    required this.profiles,
    this.activeProfile,
  });
}

/// Operação de perfil falhou
class ProfileFailure extends ProfileResult {
  final String message;
  final Exception? exception;

  const ProfileFailure({
    required this.message,
    this.exception,
  });
}

/// Operação cancelada pelo usuário
class ProfileCancelled extends ProfileResult {
  const ProfileCancelled();
}

/// Perfil não encontrado
class ProfileNotFound extends ProfileResult {
  final String profileId;

  const ProfileNotFound(this.profileId);
}

/// Validação falhou
class ProfileValidationError extends ProfileResult {
  final Map<String, String> errors;

  const ProfileValidationError(this.errors);
}
