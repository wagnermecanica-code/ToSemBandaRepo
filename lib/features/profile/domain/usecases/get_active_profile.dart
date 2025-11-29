import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// UseCase: Obter perfil ativo do usuário
class GetActiveProfileUseCase {
  final ProfileRepository _repository;
  
  GetActiveProfileUseCase(this._repository);
  
  Future<ProfileEntity?> call(String uid) async {
    return await _repository.getActiveProfile(uid);
  }
}
