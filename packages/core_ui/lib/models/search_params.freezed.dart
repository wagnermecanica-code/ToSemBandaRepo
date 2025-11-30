// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SearchParams {
  String get city => throw _privateConstructorUsedError;
  double get maxDistanceKm => throw _privateConstructorUsedError;
  String? get level => throw _privateConstructorUsedError;
  Set<String> get instruments => throw _privateConstructorUsedError;
  Set<String> get genres => throw _privateConstructorUsedError;
  String? get postType =>
      throw _privateConstructorUsedError; // 'musician' ou 'band'
  String? get availableFor =>
      throw _privateConstructorUsedError; // 'gig', 'rehearsal', etc.
  bool? get hasYoutube => throw _privateConstructorUsedError;

  /// Create a copy of SearchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchParamsCopyWith<SearchParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchParamsCopyWith<$Res> {
  factory $SearchParamsCopyWith(
          SearchParams value, $Res Function(SearchParams) then) =
      _$SearchParamsCopyWithImpl<$Res, SearchParams>;
  @useResult
  $Res call(
      {String city,
      double maxDistanceKm,
      String? level,
      Set<String> instruments,
      Set<String> genres,
      String? postType,
      String? availableFor,
      bool? hasYoutube});
}

/// @nodoc
class _$SearchParamsCopyWithImpl<$Res, $Val extends SearchParams>
    implements $SearchParamsCopyWith<$Res> {
  _$SearchParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? city = null,
    Object? maxDistanceKm = null,
    Object? level = freezed,
    Object? instruments = null,
    Object? genres = null,
    Object? postType = freezed,
    Object? availableFor = freezed,
    Object? hasYoutube = freezed,
  }) {
    return _then(_value.copyWith(
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      maxDistanceKm: null == maxDistanceKm
          ? _value.maxDistanceKm
          : maxDistanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      level: freezed == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String?,
      instruments: null == instruments
          ? _value.instruments
          : instruments // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      genres: null == genres
          ? _value.genres
          : genres // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      postType: freezed == postType
          ? _value.postType
          : postType // ignore: cast_nullable_to_non_nullable
              as String?,
      availableFor: freezed == availableFor
          ? _value.availableFor
          : availableFor // ignore: cast_nullable_to_non_nullable
              as String?,
      hasYoutube: freezed == hasYoutube
          ? _value.hasYoutube
          : hasYoutube // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchParamsImplCopyWith<$Res>
    implements $SearchParamsCopyWith<$Res> {
  factory _$$SearchParamsImplCopyWith(
          _$SearchParamsImpl value, $Res Function(_$SearchParamsImpl) then) =
      __$$SearchParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String city,
      double maxDistanceKm,
      String? level,
      Set<String> instruments,
      Set<String> genres,
      String? postType,
      String? availableFor,
      bool? hasYoutube});
}

/// @nodoc
class __$$SearchParamsImplCopyWithImpl<$Res>
    extends _$SearchParamsCopyWithImpl<$Res, _$SearchParamsImpl>
    implements _$$SearchParamsImplCopyWith<$Res> {
  __$$SearchParamsImplCopyWithImpl(
      _$SearchParamsImpl _value, $Res Function(_$SearchParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? city = null,
    Object? maxDistanceKm = null,
    Object? level = freezed,
    Object? instruments = null,
    Object? genres = null,
    Object? postType = freezed,
    Object? availableFor = freezed,
    Object? hasYoutube = freezed,
  }) {
    return _then(_$SearchParamsImpl(
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      maxDistanceKm: null == maxDistanceKm
          ? _value.maxDistanceKm
          : maxDistanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      level: freezed == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String?,
      instruments: null == instruments
          ? _value._instruments
          : instruments // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      genres: null == genres
          ? _value._genres
          : genres // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      postType: freezed == postType
          ? _value.postType
          : postType // ignore: cast_nullable_to_non_nullable
              as String?,
      availableFor: freezed == availableFor
          ? _value.availableFor
          : availableFor // ignore: cast_nullable_to_non_nullable
              as String?,
      hasYoutube: freezed == hasYoutube
          ? _value.hasYoutube
          : hasYoutube // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

class _$SearchParamsImpl implements _SearchParams {
  const _$SearchParamsImpl(
      {required this.city,
      required this.maxDistanceKm,
      this.level,
      final Set<String> instruments = const {},
      final Set<String> genres = const {},
      this.postType,
      this.availableFor,
      this.hasYoutube})
      : _instruments = instruments,
        _genres = genres;

  @override
  final String city;
  @override
  final double maxDistanceKm;
  @override
  final String? level;
  final Set<String> _instruments;
  @override
  @JsonKey()
  Set<String> get instruments {
    if (_instruments is EqualUnmodifiableSetView) return _instruments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_instruments);
  }

  final Set<String> _genres;
  @override
  @JsonKey()
  Set<String> get genres {
    if (_genres is EqualUnmodifiableSetView) return _genres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_genres);
  }

  @override
  final String? postType;
// 'musician' ou 'band'
  @override
  final String? availableFor;
// 'gig', 'rehearsal', etc.
  @override
  final bool? hasYoutube;

  @override
  String toString() {
    return 'SearchParams(city: $city, maxDistanceKm: $maxDistanceKm, level: $level, instruments: $instruments, genres: $genres, postType: $postType, availableFor: $availableFor, hasYoutube: $hasYoutube)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchParamsImpl &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.maxDistanceKm, maxDistanceKm) ||
                other.maxDistanceKm == maxDistanceKm) &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality()
                .equals(other._instruments, _instruments) &&
            const DeepCollectionEquality().equals(other._genres, _genres) &&
            (identical(other.postType, postType) ||
                other.postType == postType) &&
            (identical(other.availableFor, availableFor) ||
                other.availableFor == availableFor) &&
            (identical(other.hasYoutube, hasYoutube) ||
                other.hasYoutube == hasYoutube));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      city,
      maxDistanceKm,
      level,
      const DeepCollectionEquality().hash(_instruments),
      const DeepCollectionEquality().hash(_genres),
      postType,
      availableFor,
      hasYoutube);

  /// Create a copy of SearchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchParamsImplCopyWith<_$SearchParamsImpl> get copyWith =>
      __$$SearchParamsImplCopyWithImpl<_$SearchParamsImpl>(this, _$identity);
}

abstract class _SearchParams implements SearchParams {
  const factory _SearchParams(
      {required final String city,
      required final double maxDistanceKm,
      final String? level,
      final Set<String> instruments,
      final Set<String> genres,
      final String? postType,
      final String? availableFor,
      final bool? hasYoutube}) = _$SearchParamsImpl;

  @override
  String get city;
  @override
  double get maxDistanceKm;
  @override
  String? get level;
  @override
  Set<String> get instruments;
  @override
  Set<String> get genres;
  @override
  String? get postType; // 'musician' ou 'band'
  @override
  String? get availableFor; // 'gig', 'rehearsal', etc.
  @override
  bool? get hasYoutube;

  /// Create a copy of SearchParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchParamsImplCopyWith<_$SearchParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
