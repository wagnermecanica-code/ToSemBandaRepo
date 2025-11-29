import '../repositories/profile_repository.dart';

/// UseCase: Trocar perfil ativo
/// 
/// Validações:
/// - Perfil existe
/// - Usuário é dono do perfil
class SwitchActiveProfileUseCase {
  final ProfileRepository _repository;
  
  SwitchActiveProfileUseCase(this._repository);
  
  Future<void> call(String uid, String newProfileId) async {
    // Validação 1: Perfil existe
    final profile = await _repository.getProfileById(newProfileId);
    if (profile == null) {
      throw Exception('Perfil não encontrado');
    }
    
    // Validação 2: Ownership
    final isOwner = await _repository.isProfileOwner(newProfileId, uid);
    if (!isOwner) {
      throw Exception('Você não tem permissão para ativar este perfil');
    }
    
    // Switch
    await _repository.switchActiveProfile(uid, newProfileId);
  }
}
