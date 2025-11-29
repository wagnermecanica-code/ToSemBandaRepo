import 'package:core_ui/features/profile/domain/entities/profile_entity.dart';
import 'package:wegig_app/features/profile/domain/repositories/profile_repository.dart';

/// UseCase: Criar novo perfil
///
/// Validações:
/// - Limite de 5 perfis por usuário
/// - Nome entre 2-50 caracteres
/// - Localização válida (não pode ser 0,0)
class CreateProfileUseCase {
  CreateProfileUseCase(this._repository);
  final ProfileRepository _repository;

  Future<ProfileEntity> call(ProfileEntity profile, String uid) async {
    // Validação 1: Limite de 5 perfis
    final existingProfiles = await _repository.getAllProfiles(uid);
    if (existingProfiles.length >= 5) {
      throw Exception('Limite de 5 perfis atingido');
    }

    // Validação 2: Nome
    if (profile.name.trim().isEmpty) {
      throw Exception('Nome é obrigatório');
    }
    if (profile.name.trim().length < 2) {
      throw Exception('Nome deve ter pelo menos 2 caracteres');
    }
    if (profile.name.trim().length > 50) {
      throw Exception('Nome deve ter no máximo 50 caracteres');
    }

    // Validação 3: Localização (não pode ser 0,0 - default inválido)
    if (profile.location.latitude == 0 && profile.location.longitude == 0) {
      throw Exception('Localização inválida');
    }

    // Validação 4: City obrigatório
    if (profile.city.trim().isEmpty) {
      throw Exception('Cidade é obrigatória');
    }

    return _repository.createProfile(profile);
  }
}
