import 'package:wegig_app/features/auth/domain/entities/auth_result.dart';
import 'package:wegig_app/features/auth/domain/repositories/auth_repository.dart';

/// UseCase: Enviar email de recuperação de senha
///
/// Single Responsibility: Executar lógica para recuperação de senha
class SendPasswordResetEmailUseCase {
  SendPasswordResetEmailUseCase(this._repository);
  final AuthRepository _repository;

  /// Envia email de recuperação de senha
  ///
  /// Validações:
  /// - Email não vazio
  ///
  /// Returns AuthResult
  Future<AuthResult> call(String email) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      return const AuthFailure(
        message: 'E-mail é obrigatório',
        code: 'empty-email',
      );
    }

    return _repository.sendPasswordResetEmail(trimmedEmail);
  }
}
