import 'package:wegig_app/features/auth/domain/repositories/auth_repository.dart';

/// UseCase: Logout
///
/// Single Responsibility: Executar logout com cleanup
class SignOutUseCase {
  SignOutUseCase(this._repository);
  final AuthRepository _repository;

  /// Executa logout completo
  ///
  /// Inclui:
  /// - Firebase Auth signOut
  /// - Google Sign-In signOut
  /// - SharedPreferences clear
  /// - ImageCache clear
  Future<void> call() async {
    await _repository.signOut();
  }
}
