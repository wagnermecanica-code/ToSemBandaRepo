import 'package:core_ui/features/profile/domain/entities/profile_entity.dart';
import 'package:wegig_app/features/profile/domain/repositories/profile_repository.dart';

/// UseCase: Carregar todos os perfis do usuário
class LoadAllProfilesUseCase {
  LoadAllProfilesUseCase(this._repository);
  final ProfileRepository _repository;

  Future<List<ProfileEntity>> call(String uid) async {
    return _repository.getAllProfiles(uid);
  }
}
