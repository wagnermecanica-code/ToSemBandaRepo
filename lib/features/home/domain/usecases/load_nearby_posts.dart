import '../../domain/repositories/home_repository.dart';
import '../../../post/domain/entities/post_entity.dart';

/// UseCase para carregar posts próximos
/// Encapsula lógica de busca geoespacial
class LoadNearbyPostsUseCase {
  final HomeRepository _repository;
  
  LoadNearbyPostsUseCase(this._repository);
  
  /// Executa busca de posts próximos
  Future<List<PostEntity>> call({
    required double latitude,
    required double longitude,
    required double radiusKm,
    int limit = 50,
    String? lastPostId,
  }) async {
    return await _repository.loadNearbyPosts(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      limit: limit,
      lastPostId: lastPostId,
    );
  }
}
