import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Cadastro com email e senha
/// 
/// Single Responsibility: Executar lógica de negócio para cadastro
class SignUpWithEmailUseCase {
  final AuthRepository _repository;
  
  SignUpWithEmailUseCase(this._repository);
  
  /// Executa cadastro com email e senha
  /// 
  /// Validações:
  /// - Email não vazio e formato válido
  /// - Senha não vazia e >= 6 caracteres
  /// 
  /// Returns AuthResult
  Future<AuthResult> call(String email, String password) async {
    // Validações de negócio
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    
    if (trimmedEmail.isEmpty) {
      return const AuthFailure(
        message: 'E-mail é obrigatório',
        code: 'empty-email',
      );
    }
    
    // Validação básica de formato email
    if (!_isValidEmail(trimmedEmail)) {
      return const AuthFailure(
        message: 'E-mail inválido',
        code: 'invalid-email-format',
      );
    }
    
    if (trimmedPassword.isEmpty) {
      return const AuthFailure(
        message: 'Senha é obrigatória',
        code: 'empty-password',
      );
    }
    
    if (trimmedPassword.length < 6) {
      return const AuthFailure(
        message: 'Senha deve ter pelo menos 6 caracteres',
        code: 'weak-password',
      );
    }
    
    // Delegar para repository
    return await _repository.signUpWithEmail(trimmedEmail, trimmedPassword);
  }
  
  /// Validação básica de formato de email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
