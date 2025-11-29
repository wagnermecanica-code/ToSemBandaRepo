import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wegig_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:wegig_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wegig_app/features/auth/domain/entities/auth_result.dart';
import 'package:wegig_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wegig_app/features/auth/domain/usecases/send_email_verification.dart';
import 'package:wegig_app/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:wegig_app/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:wegig_app/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:wegig_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:wegig_app/features/auth/domain/usecases/sign_out.dart';
import 'package:wegig_app/features/auth/domain/usecases/sign_up_with_email.dart';

/// ============================================
/// DATA LAYER - Dependency Injection
/// ============================================

/// Provider para AuthRemoteDataSource (singleton)
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

/// Provider para AuthRepository (singleton)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// ============================================
/// DOMAIN LAYER - UseCases
/// ============================================

/// Provider para SignInWithEmailUseCase
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithEmailUseCase(repository);
});

/// Provider para SignUpWithEmailUseCase
final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpWithEmailUseCase(repository);
});

/// Provider para SignInWithGoogleUseCase
final signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithGoogleUseCase(repository);
});

/// Provider para SignInWithAppleUseCase
final signInWithAppleUseCaseProvider = Provider<SignInWithAppleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithAppleUseCase(repository);
});

/// Provider para SignOutUseCase
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
});

/// Provider para SendPasswordResetEmailUseCase
final sendPasswordResetEmailUseCaseProvider =
    Provider<SendPasswordResetEmailUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SendPasswordResetEmailUseCase(repository);
});

/// Provider para SendEmailVerificationUseCase
final sendEmailVerificationUseCaseProvider =
    Provider<SendEmailVerificationUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SendEmailVerificationUseCase(repository);
});

/// ============================================
/// PRESENTATION LAYER - State
/// ============================================

/// Provider para o stream de auth state changes
///
/// Reactivo - atualiza automaticamente quando user faz login/logout
///
/// MANTIDO PARA RETROCOMPATIBILIDADE COM CÓDIGO EXISTENTE
final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Provider para o usuário atual (nullable)
///
/// Útil para checagens rápidas sem async
///
/// MANTIDO PARA RETROCOMPATIBILIDADE
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// Provider para verificar se usuário está autenticado
///
/// MANTIDO PARA RETROCOMPATIBILIDADE
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Provider para verificar se email foi verificado
///
/// MANTIDO PARA RETROCOMPATIBILIDADE
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.emailVerified ?? false;
});

/// ============================================
/// FACADE - Simplificação de acesso
/// ============================================

/// Provider para AuthService (facade)
///
/// MANTIDO PARA RETROCOMPATIBILIDADE COM CÓDIGO ANTIGO
/// Fornece interface simples para código legado que usa AuthService
///
/// DEPRECATED: Novo código deve usar UseCases diretamente
@Deprecated('Use UseCases diretamente (signInWithEmailUseCaseProvider, etc)')
final authServiceProvider = Provider<IAuthService>((ref) {
  return _AuthServiceFacade(ref);
});

/// Facade que adapta nova arquitetura para interface antiga
///
/// Permite código legado funcionar sem modificações enquanto
/// migramos gradualmente para UseCases
class _AuthServiceFacade implements IAuthService {
  _AuthServiceFacade(this._ref);
  final Ref _ref;

  @override
  Stream<User?> get authStateChanges {
    return _ref.read(authRepositoryProvider).authStateChanges;
  }

  @override
  User? get currentUser {
    return _ref.read(authRepositoryProvider).currentUser;
  }

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    final useCase = _ref.read(signInWithEmailUseCaseProvider);
    return useCase(email, password);
  }

  @override
  Future<AuthResult> signUpWithEmail(String email, String password) async {
    final useCase = _ref.read(signUpWithEmailUseCaseProvider);
    return useCase(email, password);
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    final useCase = _ref.read(signInWithGoogleUseCaseProvider);
    return useCase();
  }

  @override
  Future<AuthResult> signInWithApple() async {
    final useCase = _ref.read(signInWithAppleUseCaseProvider);
    return useCase();
  }

  @override
  Future<void> signOut() async {
    final useCase = _ref.read(signOutUseCaseProvider);
    await useCase();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final useCase = _ref.read(sendPasswordResetEmailUseCaseProvider);
    await useCase(email);
  }

  @override
  Future<void> sendEmailVerification() async {
    final useCase = _ref.read(sendEmailVerificationUseCaseProvider);
    await useCase();
  }
}

/// Interface IAuthService (mantida para retrocompatibilidade)
abstract class IAuthService {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<AuthResult> signInWithEmail(String email, String password);
  Future<AuthResult> signUpWithEmail(String email, String password);
  Future<AuthResult> signInWithGoogle();
  Future<AuthResult> signInWithApple();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
}
