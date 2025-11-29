import '../../domain/repositories/home_repository.dart';
import '../../../post/domain/entities/post_entity.dart';

/// UseCase para carregar posts filtrados por gênero
/// Combina busca geoespacial com filtro de gêneros musicais
class LoadPostsByGenresUseCase {
  final HomeRepository _repository;
  
  LoadPostsByGenresUseCase(this._repository);
  
  /// Executa busca de posts por gêneros
  Future<List<PostEntity>> call({
    required List<String> genres,
    required double latitude,
    required double longitude,
    required double radiusKm,
    int limit = 50,
    String? lastPostId,
  }) async {
    return await _repository.loadPostsByGenres(
      genres: genres,
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      limit: limit,
      lastPostId: lastPostId,
    );
  }
}
