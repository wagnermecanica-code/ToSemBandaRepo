import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

/// UseCase: Login com Google
/// 
/// Single Responsibility: Executar lógica de negócio para login com Google
class SignInWithGoogleUseCase {
  final AuthRepository _repository;
  
  SignInWithGoogleUseCase(this._repository);
  
  /// Executa login com Google
  /// 
  /// Sem validações extras (Google SDK já valida)
  /// 
  /// Returns AuthResult
  Future<AuthResult> call() async {
    return await _repository.signInWithGoogle();
  }
}
