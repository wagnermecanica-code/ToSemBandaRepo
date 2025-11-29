import 'package:flutter_test/flutter_test.dart';
import 'package:wegig_app/features/post/domain/usecases/delete_post.dart';

import 'mock_post_repository.dart';

void main() {
  late DeletePost useCase;
  late MockPostRepository mockRepository;

  setUp(() {
    mockRepository = MockPostRepository();
    useCase = DeletePost(mockRepository);
  });

  group('DeletePost - Success Cases', () {
    test('should delete post when user is owner', () async {
      // given
      const postId = 'post-123';
      const userId = 'user-456';
      mockRepository.setupOwnership(postId, userId, isOwner: true);

      // when
      await useCase(postId, userId);

      // then
      expect(mockRepository.deletePostCalled, true);
      expect(mockRepository.lastDeletedPostId, postId);
    });
  });

  group('DeletePost - Ownership Validation', () {
    test('should throw when user is not post owner', () async {
      // given
      const postId = 'post-123';
      const userId = 'user-456';
      mockRepository.setupOwnership(postId, userId, isOwner: false);

      // when & then
      expect(
        () => useCase(postId, userId),
        throwsA(
          predicate((e) => e.toString().contains('Você não tem permissão para excluir este post')),
        ),
      );
    });

    test('should throw when post does not exist', () async {
      // given
      const postId = 'non-existent-post';
      const userId = 'user-456';
      mockRepository.setupOwnership(postId, userId, isOwner: false);

      // when & then
      expect(
        () => useCase(postId, userId),
        throwsA(
          predicate((e) => e.toString().contains('Você não tem permissão para excluir este post')),
        ),
      );
    });
  });

  group('DeletePost - Repository Failures', () {
    test('should propagate exception when repository fails', () async {
      // given
      const postId = 'post-123';
      const userId = 'user-456';
      mockRepository.setupOwnership(postId, userId, isOwner: true);
      mockRepository.setupDeleteFailure('Erro ao excluir post do Firestore');

      // when & then
      expect(
        () => useCase(postId, userId),
        throwsA(
          predicate((e) => e.toString().contains('Erro ao excluir post do Firestore')),
        ),
      );
    });

    test('should propagate exception when ownership check fails', () async {
      // given
      const postId = 'post-123';
      const userId = 'user-456';
      mockRepository.setupOwnershipCheckFailure('Erro ao verificar permissões');

      // when & then
      expect(
        () => useCase(postId, userId),
        throwsA(
          predicate((e) => e.toString().contains('Erro ao verificar permissões')),
        ),
      );
    });
  });

  group('DeletePost - Edge Cases', () {
    test('should handle empty postId', () async {
      // given
      const postId = '';
      const userId = 'user-456';
      mockRepository.setupOwnership(postId, userId, isOwner: false);

      // when & then
      expect(
        () => useCase(postId, userId),
        throwsA(
          predicate((e) => e.toString().contains('ID do post é obrigatório')),
        ),
      );
    });

    test('should handle empty userId', () async {
      // given
      const postId = 'post-123';
      const userId = '';

      // when & then
      expect(
        () => useCase(postId, userId),
        throwsA(
          predicate((e) => e.toString().contains('ID do usuário é obrigatório')),
        ),
      );
    });
  });
}
