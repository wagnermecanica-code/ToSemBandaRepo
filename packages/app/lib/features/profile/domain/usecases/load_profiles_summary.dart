import 'package:wegig_app/features/profile/domain/repositories/profile_repository.dart';

/// UseCase: Carregar resumo dos perfis do usuário
///
/// Usado no Profile Switcher para exibir lista de perfis
class LoadProfilesSummaryUseCase {
  LoadProfilesSummaryUseCase(this._repository);
  final ProfileRepository _repository;

  Future<List<Map<String, dynamic>>> call(String uid) async {
    return _repository.getProfilesSummary(uid);
  }
}
