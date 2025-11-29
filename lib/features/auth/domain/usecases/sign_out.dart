import '../repositories/auth_repository.dart';

/// UseCase: Logout
/// 
/// Single Responsibility: Executar logout com cleanup
class SignOutUseCase {
  final AuthRepository _repository;
  
  SignOutUseCase(this._repository);
  
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
