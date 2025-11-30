// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthResult {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AuthResult);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthResult()';
  }
}

/// @nodoc
class $AuthResultCopyWith<$Res> {
  $AuthResultCopyWith(AuthResult _, $Res Function(AuthResult) __);
}

/// Adds pattern-matching-related methods to [AuthResult].
extension AuthResultPatterns on AuthResult {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthSuccess value)? success,
    TResult Function(AuthFailure value)? failure,
    TResult Function(AuthCancelled value)? cancelled,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AuthSuccess() when success != null:
        return success(_that);
      case AuthFailure() when failure != null:
        return failure(_that);
      case AuthCancelled() when cancelled != null:
        return cancelled(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthSuccess value) success,
    required TResult Function(AuthFailure value) failure,
    required TResult Function(AuthCancelled value) cancelled,
  }) {
    final _that = this;
    switch (_that) {
      case AuthSuccess():
        return success(_that);
      case AuthFailure():
        return failure(_that);
      case AuthCancelled():
        return cancelled(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthSuccess value)? success,
    TResult? Function(AuthFailure value)? failure,
    TResult? Function(AuthCancelled value)? cancelled,
  }) {
    final _that = this;
    switch (_that) {
      case AuthSuccess() when success != null:
        return success(_that);
      case AuthFailure() when failure != null:
        return failure(_that);
      case AuthCancelled() when cancelled != null:
        return cancelled(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(User user, bool requiresEmailVerification,
            bool requiresProfileCreation)?
        success,
    TResult Function(String message, String? code)? failure,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AuthSuccess() when success != null:
        return success(_that.user, _that.requiresEmailVerification,
            _that.requiresProfileCreation);
      case AuthFailure() when failure != null:
        return failure(_that.message, _that.code);
      case AuthCancelled() when cancelled != null:
        return cancelled();
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(User user, bool requiresEmailVerification,
            bool requiresProfileCreation)
        success,
    required TResult Function(String message, String? code) failure,
    required TResult Function() cancelled,
  }) {
    final _that = this;
    switch (_that) {
      case AuthSuccess():
        return success(_that.user, _that.requiresEmailVerification,
            _that.requiresProfileCreation);
      case AuthFailure():
        return failure(_that.message, _that.code);
      case AuthCancelled():
        return cancelled();
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(User user, bool requiresEmailVerification,
            bool requiresProfileCreation)?
        success,
    TResult? Function(String message, String? code)? failure,
    TResult? Function()? cancelled,
  }) {
    final _that = this;
    switch (_that) {
      case AuthSuccess() when success != null:
        return success(_that.user, _that.requiresEmailVerification,
            _that.requiresProfileCreation);
      case AuthFailure() when failure != null:
        return failure(_that.message, _that.code);
      case AuthCancelled() when cancelled != null:
        return cancelled();
      case _:
        return null;
    }
  }
}

/// @nodoc

class AuthSuccess implements AuthResult {
  const AuthSuccess(
      {required this.user,
      this.requiresEmailVerification = false,
      this.requiresProfileCreation = false});

  final User user;
  @JsonKey()
  final bool requiresEmailVerification;
  @JsonKey()
  final bool requiresProfileCreation;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthSuccessCopyWith<AuthSuccess> get copyWith =>
      _$AuthSuccessCopyWithImpl<AuthSuccess>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthSuccess &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.requiresEmailVerification,
                    requiresEmailVerification) ||
                other.requiresEmailVerification == requiresEmailVerification) &&
            (identical(
                    other.requiresProfileCreation, requiresProfileCreation) ||
                other.requiresProfileCreation == requiresProfileCreation));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, user, requiresEmailVerification, requiresProfileCreation);

  @override
  String toString() {
    return 'AuthResult.success(user: $user, requiresEmailVerification: $requiresEmailVerification, requiresProfileCreation: $requiresProfileCreation)';
  }
}

/// @nodoc
abstract mixin class $AuthSuccessCopyWith<$Res>
    implements $AuthResultCopyWith<$Res> {
  factory $AuthSuccessCopyWith(
          AuthSuccess value, $Res Function(AuthSuccess) _then) =
      _$AuthSuccessCopyWithImpl;
  @useResult
  $Res call(
      {User user,
      bool requiresEmailVerification,
      bool requiresProfileCreation});
}

/// @nodoc
class _$AuthSuccessCopyWithImpl<$Res> implements $AuthSuccessCopyWith<$Res> {
  _$AuthSuccessCopyWithImpl(this._self, this._then);

  final AuthSuccess _self;
  final $Res Function(AuthSuccess) _then;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? user = null,
    Object? requiresEmailVerification = null,
    Object? requiresProfileCreation = null,
  }) {
    return _then(AuthSuccess(
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      requiresEmailVerification: null == requiresEmailVerification
          ? _self.requiresEmailVerification
          : requiresEmailVerification // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresProfileCreation: null == requiresProfileCreation
          ? _self.requiresProfileCreation
          : requiresProfileCreation // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class AuthFailure implements AuthResult {
  const AuthFailure({required this.message, this.code});

  final String message;
  final String? code;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AuthFailureCopyWith<AuthFailure> get copyWith =>
      _$AuthFailureCopyWithImpl<AuthFailure>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthFailure &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  @override
  String toString() {
    return 'AuthResult.failure(message: $message, code: $code)';
  }
}

/// @nodoc
abstract mixin class $AuthFailureCopyWith<$Res>
    implements $AuthResultCopyWith<$Res> {
  factory $AuthFailureCopyWith(
          AuthFailure value, $Res Function(AuthFailure) _then) =
      _$AuthFailureCopyWithImpl;
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class _$AuthFailureCopyWithImpl<$Res> implements $AuthFailureCopyWith<$Res> {
  _$AuthFailureCopyWithImpl(this._self, this._then);

  final AuthFailure _self;
  final $Res Function(AuthFailure) _then;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? code = freezed,
  }) {
    return _then(AuthFailure(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      code: freezed == code
          ? _self.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class AuthCancelled implements AuthResult {
  const AuthCancelled();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AuthCancelled);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthResult.cancelled()';
  }
}

// dart format on
