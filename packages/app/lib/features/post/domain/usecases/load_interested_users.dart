import 'package:wegig_app/features/post/domain/repositories/post_repository.dart';

/// UseCase: Carregar perfis interessados em um post
/// Retorna lista de profileIds que demonstraram interesse
class LoadInterestedUsers {
  LoadInterestedUsers(this._repository);
  final PostRepository _repository;

  Future<List<String>> call(String postId) async {
    return _repository.getInterestedProfiles(postId);
  }
}
