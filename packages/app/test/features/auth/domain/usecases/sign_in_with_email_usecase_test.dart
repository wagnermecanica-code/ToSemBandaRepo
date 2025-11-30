import 'package:flutter_test/flutter_test.dart';
import 'package:wegig_app/features/auth/domain/entities/auth_result.dart';
import 'package:wegig_app/features/auth/domain/usecases/sign_in_with_email.dart';

import 'mock_auth_repository.dart';

void main() {
  late SignInWithEmailUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithEmailUseCase(mockRepository);
  });

  group('SignInWithEmailUseCase - Validations', () {
    const tEmail = 'test@wegig.app';
    const tPassword = 'password123';

    test('should return AuthFailure when email is empty', () async {
      // Act
      final result = await useCase('', tPassword);

      // Assert
      expect(result, isA<AuthFailure>());
      final failure = result as AuthFailure;
      expect(failure.message, 'E-mail é obrigatório');
      expect(failure.code, 'empty-email');
    });

    test('should return AuthFailure when email is only spaces', () async {
      // Act
      final result = await useCase('   ', tPassword);

      // Assert
      expect(result, isA<AuthFailure>());
      final failure = result as AuthFailure;
      expect(failure.message, 'E-mail é obrigatório');
      expect(failure.code, 'empty-email');
    });

    test('should return AuthFailure when password is empty', () async {
      // Act
      final result = await useCase(tEmail, '');

      // Assert
      expect(result, isA<AuthFailure>());
      final failure = result as AuthFailure;
      expect(failure.message, 'Senha é obrigatória');
      expect(failure.code, 'empty-password');
    });

    test('should return AuthFailure when password is only spaces', () async {
      // Act
      final result = await useCase(tEmail, '   ');

      // Assert
      expect(result, isA<AuthFailure>());
      final failure = result as AuthFailure;
      expect(failure.message, 'Senha é obrigatória');
      expect(failure.code, 'empty-password');
    });

    test('should call repository with trimmed values', () async {
      // Arrange
      const emailWithSpaces = '  test@wegig.app  ';
      const passwordWithSpaces = '  password123  ';
      mockRepository.setupSuccessResponse();

      // Act
      final result = await useCase(emailWithSpaces, passwordWithSpaces);

      // Assert
      expect(result, isA<AuthSuccess>());
      expect(mockRepository.lastEmail, tEmail);
      expect(mockRepository.lastPassword, tPassword);
    });

    test('should return AuthSuccess when credentials are valid', () async {
      // Arrange
      mockRepository.setupSuccessResponse();

      // Act
      final result = await useCase(tEmail, tPassword);

      // Assert
      expect(result, isA<AuthSuccess>());
      expect(mockRepository.lastEmail, tEmail);
      expect(mockRepository.lastPassword, tPassword);
    });

    test('should return AuthFailure when repository fails', () async {
      // Arrange
      mockRepository.setupFailureResponse(
          'Credenciais inválidas', 'invalid-credential');

      // Act
      final result = await useCase(tEmail, tPassword);

      // Assert
      expect(result, isA<AuthFailure>());
      final failure = result as AuthFailure;
      expect(failure.message, 'Credenciais inválidas');
      expect(failure.code, 'invalid-credential');
    });
  });
}
