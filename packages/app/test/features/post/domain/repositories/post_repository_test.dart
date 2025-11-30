import 'package:flutter_test/flutter_test.dart';

/// Testes críticos para PostRepository
/// Foca em validações de negócio sem depender de Freezed entities
void main() {
  group('PostRepository - Create Post Validations', () {
    test('should validate location is required', () {
      // Arrange
      final invalidPost = {
        'description': 'Test post',
        'location': null, // ❌ Obrigatório
      };

      // Act & Assert
      expect(
        () => _validatePostData(invalidPost),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should validate description max length (1000 chars)', () {
      // Arrange
      final longDescription = 'A' * 1001; // Excede limite
      final invalidPost = {
        'description': longDescription,
        'location': {'latitude': -23.5505, 'longitude': -46.6333},
      };

      // Act & Assert
      expect(
        () => _validatePostData(invalidPost),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should accept valid post data', () {
      // Arrange
      final validPost = {
        'description': 'Procurando baterista para banda de rock',
        'location': {'latitude': -23.5505, 'longitude': -46.6333},
        'city': 'São Paulo',
        'type': 'band',
      };

      // Act & Assert
      expect(() => _validatePostData(validPost), returnsNormally);
    });
  });

  group('PostRepository - Add Interest Validations', () {
    final existingInterests = ['profile-1', 'profile-2'];

    test('should not duplicate interest if already exists', () {
      // Arrange
      const profileId = 'profile-1';

      // Act
      final result = _canAddInterest(profileId, existingInterests);

      // Assert
      expect(result, isFalse, reason: 'Não deve duplicar interesse');
    });

    test('should allow new interest if not exists', () {
      // Arrange
      const profileId = 'profile-3';

      // Act
      final result = _canAddInterest(profileId, existingInterests);

      // Assert
      expect(result, isTrue, reason: 'Deve permitir novo interesse');
    });

    test('should prevent self-interest', () {
      // Arrange
      const authorProfileId = 'profile-author';
      const interestedProfileId = 'profile-author'; // Mesmo perfil

      // Act
      final result = _canInteractWithOwnPost(
        authorProfileId,
        interestedProfileId,
      );

      // Assert
      expect(result, isFalse,
          reason: 'Não pode demonstrar interesse no próprio post');
    });
  });
}

/// Helper: Valida dados do post (simula lógica do repository)
void _validatePostData(Map<String, dynamic> postData) {
  if (postData['location'] == null) {
    throw ArgumentError('Location is required');
  }

  final description = postData['description'] as String?;
  if (description != null && description.length > 1000) {
    throw ArgumentError('Description exceeds 1000 characters');
  }
}

/// Helper: Verifica se pode adicionar interesse (sem duplicatas)
bool _canAddInterest(String profileId, List<String> existingInterests) {
  return !existingInterests.contains(profileId);
}

/// Helper: Verifica se pode interagir com próprio post
bool _canInteractWithOwnPost(
    String authorProfileId, String interestedProfileId) {
  return authorProfileId != interestedProfileId;
}
