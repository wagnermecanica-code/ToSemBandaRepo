import '../repositories/post_repository.dart';

/// UseCase: Deletar um post
/// Valida ownership antes de deletar
class DeletePost {
  final PostRepository _repository;

  DeletePost(this._repository);

  Future<void> call(String postId, String profileId) async {
    return await _repository.deletePost(postId, profileId);
  }
}
