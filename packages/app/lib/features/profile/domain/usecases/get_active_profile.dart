import 'package:core_ui/features/profile/domain/entities/profile_entity.dart';
import 'package:wegig_app/features/profile/domain/repositories/profile_repository.dart';

/// UseCase: Obter perfil ativo do usuário
class GetActiveProfileUseCase {
  GetActiveProfileUseCase(this._repository);
  final ProfileRepository _repository;

  Future<ProfileEntity?> call(String uid) async {
    return _repository.getActiveProfile(uid);
  }
}
