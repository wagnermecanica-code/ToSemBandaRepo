import 'package:flutter_test/flutter_test.dart';
import 'package:wegig_app/features/post/domain/usecases/load_interested_users.dart';

import 'mock_post_repository.dart';

void main() {
  late LoadInterestedUsers useCase;
  late MockPostRepository mockRepository;

  setUp(() {
    mockRepository = MockPostRepository();
    useCase = LoadInterestedUsers(mockRepository);
  });

  group('LoadInterestedUsers - Success Cases', () {
    test('should return list of interested profile IDs', () async {
      // given
      const postId = 'post-1';
      const interestedProfiles = ['profile-1', 'profile-2', 'profile-3'];
      mockRepository.setupInterestedProfiles(postId, interestedProfiles);

      // when
      final result = await useCase(postId);

      // then
      expect(result, interestedProfiles);
      expect(result.length, 3);
    });

    test('should return empty list when no one is interested', () async {
      // given
      const postId = 'post-1';
      mockRepository.setupInterestedProfiles(postId, []);

      // when
      final result = await useCase(postId);

      // then
      expect(result, isEmpty);
    });
  });

  group('LoadInterestedUsers - Validation', () {
    test('should throw when postId is empty', () async {
      // given
      const postId = '';

      // when & then
      expect(
        () => useCase(postId),
        throwsA(
          predicate((e) => e.toString().contains('ID do post é obrigatório')),
        ),
      );
    });
  });

  group('LoadInterestedUsers - Edge Cases', () {
    test('should handle large number of interested profiles', () async {
      // given
      const postId = 'post-popular';
      final largeList = List.generate(100, (i) => 'profile-$i');
      mockRepository.setupInterestedProfiles(postId, largeList);

      // when
      final result = await useCase(postId);

      // then
      expect(result.length, 100);
      expect(result.first, 'profile-0');
      expect(result.last, 'profile-99');
    });

    test('should handle post that does not exist', () async {
      // given
      const postId = 'non-existent-post';
      mockRepository.setupInterestedProfiles(postId, []);

      // when
      final result = await useCase(postId);

      // then
      expect(result, isEmpty);
    });
  });

  group('LoadInterestedUsers - Repository Failures', () {
    test('should propagate exception when repository fails', () async {
      // given
      const postId = 'post-1';
      mockRepository.setupInterestedProfilesFailure(
          'Erro ao carregar interessados do Firestore');

      // when & then
      expect(
        () => useCase(postId),
        throwsA(
          predicate((e) => e
              .toString()
              .contains('Erro ao carregar interessados do Firestore')),
        ),
      );
    });
  });
}
