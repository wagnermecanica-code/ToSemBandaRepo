import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// UseCase: Carregar todos os perfis do usuário
class LoadAllProfilesUseCase {
  final ProfileRepository _repository;
  
  LoadAllProfilesUseCase(this._repository);
  
  Future<List<ProfileEntity>> call(String uid) async {
    return await _repository.getAllProfiles(uid);
  }
}
