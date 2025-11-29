import '../repositories/profile_repository.dart';

/// UseCase: Deletar perfil
/// 
/// Validações:
/// - Perfil existe
/// - Usuário é dono do perfil
/// - Se deletar perfil ativo, exigir newActiveProfileId
/// - Não pode deletar último perfil
class DeleteProfileUseCase {
  final ProfileRepository _repository;
  
  DeleteProfileUseCase(this._repository);
  
  Future<void> call(
    String profileId,
    String uid, {
    String? newActiveProfileId,
  }) async {
    // Validação 1: Perfil existe
    final profile = await _repository.getProfileById(profileId);
    if (profile == null) {
      throw Exception('Perfil não encontrado');
    }
    
    // Validação 2: Ownership
    final isOwner = await _repository.isProfileOwner(profileId, uid);
    if (!isOwner) {
      throw Exception('Você não tem permissão para deletar este perfil');
    }
    
    // Validação 3: Não pode deletar último perfil
    final allProfiles = await _repository.getAllProfiles(uid);
    if (allProfiles.length <= 1) {
      throw Exception('Você precisa ter pelo menos um perfil');
    }
    
    // Validação 4: Se deletar perfil ativo, exigir newActiveProfileId
    final activeProfile = await _repository.getActiveProfile(uid);
    if (activeProfile?.profileId == profileId && newActiveProfileId == null) {
      throw Exception('Selecione outro perfil antes de deletar o ativo');
    }
    
    // Delete
    await _repository.deleteProfile(
      profileId,
      newActiveProfileId: newActiveProfileId,
    );
  }
}
