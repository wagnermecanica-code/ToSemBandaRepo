import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Login com email e senha
/// 
/// Single Responsibility: Executar lógica de negócio para login com email
class SignInWithEmailUseCase {
  final AuthRepository _repository;
  
  SignInWithEmailUseCase(this._repository);
  
  /// Executa login com email e senha
  /// 
  /// Validações:
  /// - Email não vazio
  /// - Senha não vazia
  /// 
  /// Returns AuthResult
  Future<AuthResult> call(String email, String password) async {
    // Validações básicas (regras de negócio)
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    
    if (trimmedEmail.isEmpty) {
      return const AuthFailure(
        message: 'E-mail é obrigatório',
        code: 'empty-email',
      );
    }
    
    if (trimmedPassword.isEmpty) {
      return const AuthFailure(
        message: 'Senha é obrigatória',
        code: 'empty-password',
      );
    }
    
    // Delegar para repository
    return await _repository.signInWithEmail(trimmedEmail, trimmedPassword);
  }
}
