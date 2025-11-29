import 'package:wegig_app/features/auth/domain/entities/auth_result.dart';
import 'package:wegig_app/features/auth/domain/repositories/auth_repository.dart';

/// UseCase: Login com Google
///
/// Single Responsibility: Executar lógica de negócio para login com Google
class SignInWithGoogleUseCase {
  SignInWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  /// Executa login com Google
  ///
  /// Sem validações extras (Google SDK já valida)
  ///
  /// Returns AuthResult
  Future<AuthResult> call() async {
    return _repository.signInWithGoogle();
  }
}
