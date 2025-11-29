import '../repositories/post_repository.dart';

/// UseCase: Carregar perfis interessados em um post
/// Retorna lista de profileIds que demonstraram interesse
class LoadInterestedUsers {
  final PostRepository _repository;

  LoadInterestedUsers(this._repository);

  Future<List<String>> call(String postId) async {
    return await _repository.getInterestedProfiles(postId);
  }
}
