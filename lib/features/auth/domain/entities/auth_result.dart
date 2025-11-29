import 'package:firebase_auth/firebase_auth.dart';

/// Resultado de operações de autenticação
/// 
/// Sealed class para type-safety e exhaustive pattern matching
sealed class AuthResult {
  const AuthResult();
}

/// Autenticação bem-sucedida
class AuthSuccess extends AuthResult {
  final User user;
  final bool requiresEmailVerification;
  final bool requiresProfileCreation;
  
  const AuthSuccess({
    required this.user,
    this.requiresEmailVerification = false,
    this.requiresProfileCreation = false,
  });
}

/// Falha na autenticação
class AuthFailure extends AuthResult {
  final String message;
  final String? code;
  
  const AuthFailure({
    required this.message,
    this.code,
  });
}

/// Operação cancelada pelo usuário
class AuthCancelled extends AuthResult {
  const AuthCancelled();
}

/// Extension para facilitar pattern matching
extension AuthResultX on AuthResult {
  T when<T>({
    required T Function(AuthSuccess) success,
    required T Function(AuthFailure) failure,
    required T Function(AuthCancelled) cancelled,
  }) {
    final result = this;
    if (result is AuthSuccess) return success(result);
    if (result is AuthFailure) return failure(result);
    if (result is AuthCancelled) return cancelled(result);
    throw Exception('Unhandled AuthResult type: $runtimeType');
  }
  
  T maybeWhen<T>({
    T Function(AuthSuccess)? success,
    T Function(AuthFailure)? failure,
    T Function(AuthCancelled)? cancelled,
    required T Function() orElse,
  }) {
    final result = this;
    if (result is AuthSuccess && success != null) return success(result);
    if (result is AuthFailure && failure != null) return failure(result);
    if (result is AuthCancelled && cancelled != null) return cancelled(result);
    return orElse();
  }
}
