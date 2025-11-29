import 'package:wegig_app/features/auth/domain/entities/auth_result.dart';
import 'package:wegig_app/features/auth/domain/repositories/auth_repository.dart';

/// UseCase: Enviar email de verificação
///
/// Single Responsibility: Enviar email de verificação para usuário atual
class SendEmailVerificationUseCase {
  SendEmailVerificationUseCase(this._repository);
  final AuthRepository _repository;

  /// Envia email de verificação
  ///
  /// Requer usuário logado
  ///
  /// Returns AuthResult
  Future<AuthResult> call() async {
    if (_repository.currentUser == null) {
      return const AuthFailure(
        message: 'Nenhum usuário logado',
        code: 'no-current-user',
      );
    }

    return _repository.sendEmailVerification();
  }
}
