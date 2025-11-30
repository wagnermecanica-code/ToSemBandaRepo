import 'package:freezed_annotation/freezed_annotation.dart';

part 'ui_state.freezed.dart';

/// Generic UI state representation for async operations
/// 
/// Usage:
/// ```dart
/// final state = UIState<List<Post>>.loading();
/// 
/// state.when(
///   initial: () => Text('Ready'),
///   loading: () => CircularProgressIndicator(),
///   success: (posts) => PostList(posts),
///   error: (message) => ErrorWidget(message),
/// );
/// ```
@freezed
class UIState<T> with _$UIState<T> {
  /// Initial state before any action
  const factory UIState.initial() = Initial<T>;

  /// Loading state during async operation
  const factory UIState.loading() = Loading<T>;

  /// Success state with data
  const factory UIState.success(T data) = Success<T>;

  /// Error state with message
  const factory UIState.error(String message) = Error<T>;
}

/// Extension methods for UIState
extension UIStateX<T> on UIState<T> {
  /// Check if state is initial
  bool get isInitial => this is Initial<T>;

  /// Check if state is loading
  bool get isLoading => this is Loading<T>;

  /// Check if state is success
  bool get isSuccess => this is Success<T>;

  /// Check if state is error
  bool get isError => this is Error<T>;

  /// Get data if success, null otherwise
  T? get dataOrNull => maybeWhen(
        success: (data) => data,
        orElse: () => null,
      );

  /// Get error message if error, null otherwise
  String? get errorOrNull => maybeWhen(
        error: (message) => message,
        orElse: () => null,
      );
}
