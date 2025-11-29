import 'package:core_ui/features/post/domain/entities/post_entity.dart';

/// Resultado type-safe para operações de post
sealed class PostResult {
  const PostResult();
}

/// Operação de post bem-sucedida
class PostSuccess extends PostResult {
  final PostEntity post;
  final String? message;

  const PostSuccess({
    required this.post,
    this.message,
  });
}

/// Lista de posts carregada com sucesso
class PostListSuccess extends PostResult {
  final List<PostEntity> posts;

  const PostListSuccess(this.posts);
}

/// Operação de post falhou
class PostFailure extends PostResult {
  final String message;
  final Exception? exception;

  const PostFailure({
    required this.message,
    this.exception,
  });
}

/// Post não encontrado
class PostNotFound extends PostResult {
  final String postId;

  const PostNotFound(this.postId);
}

/// Validação falhou
class PostValidationError extends PostResult {
  final Map<String, String> errors;

  const PostValidationError(this.errors);
}

/// Interest toggle result
class InterestToggleSuccess extends PostResult {
  final bool hasInterest; // true = added, false = removed

  const InterestToggleSuccess(this.hasInterest);
}
