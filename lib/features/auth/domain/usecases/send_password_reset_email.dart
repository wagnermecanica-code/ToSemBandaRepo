import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Enviar email de recuperação de senha
/// 
/// Single Responsibility: Executar lógica para recuperação de senha
class SendPasswordResetEmailUseCase {
  final AuthRepository _repository;
  
  SendPasswordResetEmailUseCase(this._repository);
  
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
    
    return await _repository.sendPasswordResetEmail(trimmedEmail);
  }
}
