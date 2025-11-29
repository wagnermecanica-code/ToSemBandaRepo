import '../repositories/profile_repository.dart';

/// UseCase: Carregar resumo dos perfis do usuário
/// 
/// Usado no Profile Switcher para exibir lista de perfis
class LoadProfilesSummaryUseCase {
  final ProfileRepository _repository;
  
  LoadProfilesSummaryUseCase(this._repository);
  
  Future<List<Map<String, dynamic>>> call(String uid) async {
    return await _repository.getProfilesSummary(uid);
  }
}
