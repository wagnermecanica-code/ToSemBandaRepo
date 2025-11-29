import 'package:wegig_app/features/auth/domain/entities/auth_result.dart';
import 'package:wegig_app/features/auth/domain/repositories/auth_repository.dart';

/// UseCase: Login com Apple
///
/// Single Responsibility: Executar lógica de negócio para login com Apple
class SignInWithAppleUseCase {
  SignInWithAppleUseCase(this._repository);
  final AuthRepository _repository;

  /// Executa login com Apple
  ///
  /// Sem validações extras (Apple SDK já valida)
  ///
  /// Returns AuthResult
  Future<AuthResult> call() async {
    return _repository.signInWithApple();
  }
}
