import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Enviar email de verificação
/// 
/// Single Responsibility: Enviar email de verificação para usuário atual
class SendEmailVerificationUseCase {
  final AuthRepository _repository;
  
  SendEmailVerificationUseCase(this._repository);
  
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
    
    return await _repository.sendEmailVerification();
  }
}
