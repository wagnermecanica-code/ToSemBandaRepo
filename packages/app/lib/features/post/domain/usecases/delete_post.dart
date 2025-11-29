import 'package:wegig_app/features/post/domain/repositories/post_repository.dart';

/// UseCase: Deletar um post
/// Valida ownership antes de deletar
class DeletePost {
  DeletePost(this._repository);
  final PostRepository _repository;

  Future<void> call(String postId, String profileId) async {
    return _repository.deletePost(postId, profileId);
  }
}
