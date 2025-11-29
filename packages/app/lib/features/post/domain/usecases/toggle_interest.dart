import 'package:wegig_app/features/post/domain/repositories/post_repository.dart';

/// UseCase: Toggle interest em um post (Instagram-style interested users)
/// Adiciona ou remove interesse de um perfil em um post
class ToggleInterest {
  ToggleInterest(this._repository);
  final PostRepository _repository;

  Future<bool> call(String postId, String profileId) async {
    final hasInterest = await _repository.hasInterest(postId, profileId);

    if (hasInterest) {
      await _repository.removeInterest(postId, profileId);
      return false; // Interest removed
    } else {
      await _repository.addInterest(postId, profileId);
      return true; // Interest added (notification sent by Cloud Function)
    }
  }
}
