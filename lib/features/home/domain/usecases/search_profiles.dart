import '../repositories/home_repository.dart';
import '../../../profile/domain/entities/profile_entity.dart';

/// UseCase para buscar perfis
/// Encapsula lógica de busca por nome, instrumento e cidade
class SearchProfilesUseCase {
  final HomeRepository _repository;
  
  SearchProfilesUseCase(this._repository);
  
  /// Executa busca de perfis
  Future<List<ProfileEntity>> call({
    String? name,
    String? instrument,
    String? city,
    int limit = 20,
  }) async {
    return await _repository.searchProfiles(
      name: name,
      instrument: instrument,
      city: city,
      limit: limit,
    );
  }
}
