// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeedState {
  List<PostEntity> get posts => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  String? get lastPostId => throw _privateConstructorUsedError;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedStateCopyWith<FeedState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedStateCopyWith<$Res> {
  factory $FeedStateCopyWith(FeedState value, $Res Function(FeedState) then) =
      _$FeedStateCopyWithImpl<$Res, FeedState>;
  @useResult
  $Res call(
      {List<PostEntity> posts,
      bool isLoading,
      String? error,
      bool hasMore,
      String? lastPostId});
}

/// @nodoc
class _$FeedStateCopyWithImpl<$Res, $Val extends FeedState>
    implements $FeedStateCopyWith<$Res> {
  _$FeedStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? posts = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? hasMore = null,
    Object? lastPostId = freezed,
  }) {
    return _then(_value.copyWith(
      posts: null == posts
          ? _value.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostEntity>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPostId: freezed == lastPostId
          ? _value.lastPostId
          : lastPostId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedStateImplCopyWith<$Res>
    implements $FeedStateCopyWith<$Res> {
  factory _$$FeedStateImplCopyWith(
          _$FeedStateImpl value, $Res Function(_$FeedStateImpl) then) =
      __$$FeedStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<PostEntity> posts,
      bool isLoading,
      String? error,
      bool hasMore,
      String? lastPostId});
}

/// @nodoc
class __$$FeedStateImplCopyWithImpl<$Res>
    extends _$FeedStateCopyWithImpl<$Res, _$FeedStateImpl>
    implements _$$FeedStateImplCopyWith<$Res> {
  __$$FeedStateImplCopyWithImpl(
      _$FeedStateImpl _value, $Res Function(_$FeedStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? posts = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? hasMore = null,
    Object? lastPostId = freezed,
  }) {
    return _then(_$FeedStateImpl(
      posts: null == posts
          ? _value._posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostEntity>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPostId: freezed == lastPostId
          ? _value.lastPostId
          : lastPostId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$FeedStateImpl implements _FeedState {
  const _$FeedStateImpl(
      {final List<PostEntity> posts = const [],
      this.isLoading = false,
      this.error,
      this.hasMore = true,
      this.lastPostId})
      : _posts = posts;

  final List<PostEntity> _posts;
  @override
  @JsonKey()
  List<PostEntity> get posts {
    if (_posts is EqualUnmodifiableListView) return _posts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_posts);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  final String? lastPostId;

  @override
  String toString() {
    return 'FeedState(posts: $posts, isLoading: $isLoading, error: $error, hasMore: $hasMore, lastPostId: $lastPostId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedStateImpl &&
            const DeepCollectionEquality().equals(other._posts, _posts) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.lastPostId, lastPostId) ||
                other.lastPostId == lastPostId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_posts),
      isLoading,
      error,
      hasMore,
      lastPostId);

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      __$$FeedStateImplCopyWithImpl<_$FeedStateImpl>(this, _$identity);
}

abstract class _FeedState implements FeedState {
  const factory _FeedState(
      {final List<PostEntity> posts,
      final bool isLoading,
      final String? error,
      final bool hasMore,
      final String? lastPostId}) = _$FeedStateImpl;

  @override
  List<PostEntity> get posts;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  bool get hasMore;
  @override
  String? get lastPostId;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProfileSearchState {
  List<ProfileEntity> get profiles => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of ProfileSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileSearchStateCopyWith<ProfileSearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileSearchStateCopyWith<$Res> {
  factory $ProfileSearchStateCopyWith(
          ProfileSearchState value, $Res Function(ProfileSearchState) then) =
      _$ProfileSearchStateCopyWithImpl<$Res, ProfileSearchState>;
  @useResult
  $Res call({List<ProfileEntity> profiles, bool isLoading, String? error});
}

/// @nodoc
class _$ProfileSearchStateCopyWithImpl<$Res, $Val extends ProfileSearchState>
    implements $ProfileSearchStateCopyWith<$Res> {
  _$ProfileSearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profiles = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      profiles: null == profiles
          ? _value.profiles
          : profiles // ignore: cast_nullable_to_non_nullable
              as List<ProfileEntity>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileSearchStateImplCopyWith<$Res>
    implements $ProfileSearchStateCopyWith<$Res> {
  factory _$$ProfileSearchStateImplCopyWith(_$ProfileSearchStateImpl value,
          $Res Function(_$ProfileSearchStateImpl) then) =
      __$$ProfileSearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ProfileEntity> profiles, bool isLoading, String? error});
}

/// @nodoc
class __$$ProfileSearchStateImplCopyWithImpl<$Res>
    extends _$ProfileSearchStateCopyWithImpl<$Res, _$ProfileSearchStateImpl>
    implements _$$ProfileSearchStateImplCopyWith<$Res> {
  __$$ProfileSearchStateImplCopyWithImpl(_$ProfileSearchStateImpl _value,
      $Res Function(_$ProfileSearchStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProfileSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profiles = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$ProfileSearchStateImpl(
      profiles: null == profiles
          ? _value._profiles
          : profiles // ignore: cast_nullable_to_non_nullable
              as List<ProfileEntity>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ProfileSearchStateImpl implements _ProfileSearchState {
  const _$ProfileSearchStateImpl(
      {final List<ProfileEntity> profiles = const [],
      this.isLoading = false,
      this.error})
      : _profiles = profiles;

  final List<ProfileEntity> _profiles;
  @override
  @JsonKey()
  List<ProfileEntity> get profiles {
    if (_profiles is EqualUnmodifiableListView) return _profiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_profiles);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'ProfileSearchState(profiles: $profiles, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileSearchStateImpl &&
            const DeepCollectionEquality().equals(other._profiles, _profiles) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_profiles), isLoading, error);

  /// Create a copy of ProfileSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileSearchStateImplCopyWith<_$ProfileSearchStateImpl> get copyWith =>
      __$$ProfileSearchStateImplCopyWithImpl<_$ProfileSearchStateImpl>(
          this, _$identity);
}

abstract class _ProfileSearchState implements ProfileSearchState {
  const factory _ProfileSearchState(
      {final List<ProfileEntity> profiles,
      final bool isLoading,
      final String? error}) = _$ProfileSearchStateImpl;

  @override
  List<ProfileEntity> get profiles;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of ProfileSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileSearchStateImplCopyWith<_$ProfileSearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
