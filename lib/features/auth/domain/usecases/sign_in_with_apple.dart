import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Login com Apple
/// 
/// Single Responsibility: Executar lógica de negócio para login com Apple
class SignInWithAppleUseCase {
  final AuthRepository _repository;
  
  SignInWithAppleUseCase(this._repository);
  
  /// Executa login com Apple
  /// 
  /// Sem validações extras (Apple SDK já valida)
  /// 
  /// Returns AuthResult
  Future<AuthResult> call() async {
    return await _repository.signInWithApple();
  }
}
