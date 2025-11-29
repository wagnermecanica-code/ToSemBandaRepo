import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// UseCase: Atualizar perfil existente
/// 
/// Validações:
/// - Nome entre 2-50 caracteres
/// - Localização válida
/// - Usuário é dono do perfil
class UpdateProfileUseCase {
  final ProfileRepository _repository;
  
  UpdateProfileUseCase(this._repository);
  
  Future<ProfileEntity> call(ProfileEntity profile, String uid) async {
    // Validação 1: Ownership
    final isOwner = await _repository.isProfileOwner(profile.profileId, uid);
    if (!isOwner) {
      throw Exception('Você não tem permissão para editar este perfil');
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
    
    // Validação 3: Localização
    if (profile.location.latitude == 0 && profile.location.longitude == 0) {
      throw Exception('Localização inválida');
    }
    
    // Validação 4: City obrigatório
    if (profile.city.trim().isEmpty) {
      throw Exception('Cidade é obrigatória');
    }
    
    return await _repository.updateProfile(profile);
  }
}
