import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// Generic Result type for operations that can succeed or fail
/// 
/// Usage:
/// ```dart
/// Future<Result<User, String>> login(String email, String password) async {
///   try {
///     final user = await authService.login(email, password);
///     return Result.success(user);
///   } catch (e) {
///     return Result.failure(e.toString());
///   }
/// }
/// 
/// final result = await login('email@example.com', 'password');
/// result.when(
///   success: (user) => Navigator.pushReplacement(...),
///   failure: (error) => showErrorDialog(error),
/// );
/// ```
@freezed
class Result<T, E> with _$Result<T, E> {
  /// Success state with value
  const factory Result.success(T value) = Success<T, E>;

  /// Failure state with error
  const factory Result.failure(E error) = Failure<T, E>;
}

/// Extension methods for Result
extension ResultX<T, E> on Result<T, E> {
  /// Check if result is success
  bool get isSuccess => this is Success<T, E>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T, E>;

  /// Get value if success, null otherwise
  T? get valueOrNull => maybeWhen(
        success: (value) => value,
        orElse: () => null,
      );

  /// Get error if failure, null otherwise
  E? get errorOrNull => maybeWhen(
        failure: (error) => error,
        orElse: () => null,
      );

  /// Get value if success, throw if failure
  T getOrThrow() => when(
        success: (value) => value,
        failure: (error) => throw error as Object,
      );

  /// Get value if success, return default otherwise
  T getOrElse(T Function() defaultValue) => when(
        success: (value) => value,
        failure: (_) => defaultValue(),
      );

  /// Transform success value
  Result<R, E> transform<R>(R Function(T value) fn) => when(
        success: (value) => Result.success(fn(value)),
        failure: (error) => Result.failure(error),
      );

  /// Transform failure error
  Result<T, R> transformError<R>(R Function(E error) fn) => when(
        success: (value) => Result.success(value),
        failure: (error) => Result.failure(fn(error)),
      );

  /// Flat map for chaining operations
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) => when(
        success: (value) => transform(value),
        failure: (error) => Result.failure(error),
      );
}
