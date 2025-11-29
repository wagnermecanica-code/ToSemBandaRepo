// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$NotificationEntity {
  String get notificationId => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  String get recipientUid => throw _privateConstructorUsedError;
  String get recipientProfileId => throw _privateConstructorUsedError;
  String? get senderUid => throw _privateConstructorUsedError;
  String? get senderProfileId => throw _privateConstructorUsedError;
  String? get senderName => throw _privateConstructorUsedError;
  String? get senderPhoto => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  NotificationActionType? get actionType => throw _privateConstructorUsedError;
  Map<String, dynamic>? get actionData => throw _privateConstructorUsedError;
  NotificationPriority get priority => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get read => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get readAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Create a copy of NotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationEntityCopyWith<NotificationEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationEntityCopyWith<$Res> {
  factory $NotificationEntityCopyWith(
    NotificationEntity value,
    $Res Function(NotificationEntity) then,
  ) = _$NotificationEntityCopyWithImpl<$Res, NotificationEntity>;
  @useResult
  $Res call({
    String notificationId,
    NotificationType type,
    String recipientUid,
    String recipientProfileId,
    String? senderUid,
    String? senderProfileId,
    String? senderName,
    String? senderPhoto,
    String title,
    String message,
    Map<String, dynamic> data,
    NotificationActionType? actionType,
    Map<String, dynamic>? actionData,
    NotificationPriority priority,
    @TimestampConverter() DateTime createdAt,
    bool read,
    @NullableTimestampConverter() DateTime? readAt,
    @NullableTimestampConverter() DateTime? expiresAt,
  });
}

/// @nodoc
class _$NotificationEntityCopyWithImpl<$Res, $Val extends NotificationEntity>
    implements $NotificationEntityCopyWith<$Res> {
  _$NotificationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationId = null,
    Object? type = null,
    Object? recipientUid = null,
    Object? recipientProfileId = null,
    Object? senderUid = freezed,
    Object? senderProfileId = freezed,
    Object? senderName = freezed,
    Object? senderPhoto = freezed,
    Object? title = null,
    Object? message = null,
    Object? data = null,
    Object? actionType = freezed,
    Object? actionData = freezed,
    Object? priority = null,
    Object? createdAt = null,
    Object? read = null,
    Object? readAt = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            notificationId: null == notificationId
                ? _value.notificationId
                : notificationId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationType,
            recipientUid: null == recipientUid
                ? _value.recipientUid
                : recipientUid // ignore: cast_nullable_to_non_nullable
                      as String,
            recipientProfileId: null == recipientProfileId
                ? _value.recipientProfileId
                : recipientProfileId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderUid: freezed == senderUid
                ? _value.senderUid
                : senderUid // ignore: cast_nullable_to_non_nullable
                      as String?,
            senderProfileId: freezed == senderProfileId
                ? _value.senderProfileId
                : senderProfileId // ignore: cast_nullable_to_non_nullable
                      as String?,
            senderName: freezed == senderName
                ? _value.senderName
                : senderName // ignore: cast_nullable_to_non_nullable
                      as String?,
            senderPhoto: freezed == senderPhoto
                ? _value.senderPhoto
                : senderPhoto // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            actionType: freezed == actionType
                ? _value.actionType
                : actionType // ignore: cast_nullable_to_non_nullable
                      as NotificationActionType?,
            actionData: freezed == actionData
                ? _value.actionData
                : actionData // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as NotificationPriority,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            read: null == read
                ? _value.read
                : read // ignore: cast_nullable_to_non_nullable
                      as bool,
            readAt: freezed == readAt
                ? _value.readAt
                : readAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationEntityImplCopyWith<$Res>
    implements $NotificationEntityCopyWith<$Res> {
  factory _$$NotificationEntityImplCopyWith(
    _$NotificationEntityImpl value,
    $Res Function(_$NotificationEntityImpl) then,
  ) = __$$NotificationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String notificationId,
    NotificationType type,
    String recipientUid,
    String recipientProfileId,
    String? senderUid,
    String? senderProfileId,
    String? senderName,
    String? senderPhoto,
    String title,
    String message,
    Map<String, dynamic> data,
    NotificationActionType? actionType,
    Map<String, dynamic>? actionData,
    NotificationPriority priority,
    @TimestampConverter() DateTime createdAt,
    bool read,
    @NullableTimestampConverter() DateTime? readAt,
    @NullableTimestampConverter() DateTime? expiresAt,
  });
}

/// @nodoc
class __$$NotificationEntityImplCopyWithImpl<$Res>
    extends _$NotificationEntityCopyWithImpl<$Res, _$NotificationEntityImpl>
    implements _$$NotificationEntityImplCopyWith<$Res> {
  __$$NotificationEntityImplCopyWithImpl(
    _$NotificationEntityImpl _value,
    $Res Function(_$NotificationEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notificationId = null,
    Object? type = null,
    Object? recipientUid = null,
    Object? recipientProfileId = null,
    Object? senderUid = freezed,
    Object? senderProfileId = freezed,
    Object? senderName = freezed,
    Object? senderPhoto = freezed,
    Object? title = null,
    Object? message = null,
    Object? data = null,
    Object? actionType = freezed,
    Object? actionData = freezed,
    Object? priority = null,
    Object? createdAt = null,
    Object? read = null,
    Object? readAt = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(
      _$NotificationEntityImpl(
        notificationId: null == notificationId
            ? _value.notificationId
            : notificationId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationType,
        recipientUid: null == recipientUid
            ? _value.recipientUid
            : recipientUid // ignore: cast_nullable_to_non_nullable
                  as String,
        recipientProfileId: null == recipientProfileId
            ? _value.recipientProfileId
            : recipientProfileId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderUid: freezed == senderUid
            ? _value.senderUid
            : senderUid // ignore: cast_nullable_to_non_nullable
                  as String?,
        senderProfileId: freezed == senderProfileId
            ? _value.senderProfileId
            : senderProfileId // ignore: cast_nullable_to_non_nullable
                  as String?,
        senderName: freezed == senderName
            ? _value.senderName
            : senderName // ignore: cast_nullable_to_non_nullable
                  as String?,
        senderPhoto: freezed == senderPhoto
            ? _value.senderPhoto
            : senderPhoto // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        actionType: freezed == actionType
            ? _value.actionType
            : actionType // ignore: cast_nullable_to_non_nullable
                  as NotificationActionType?,
        actionData: freezed == actionData
            ? _value._actionData
            : actionData // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as NotificationPriority,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        read: null == read
            ? _value.read
            : read // ignore: cast_nullable_to_non_nullable
                  as bool,
        readAt: freezed == readAt
            ? _value.readAt
            : readAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$NotificationEntityImpl extends _NotificationEntity {
  const _$NotificationEntityImpl({
    required this.notificationId,
    required this.type,
    required this.recipientUid,
    required this.recipientProfileId,
    this.senderUid,
    this.senderProfileId,
    this.senderName,
    this.senderPhoto,
    required this.title,
    required this.message,
    final Map<String, dynamic> data = const {},
    this.actionType,
    final Map<String, dynamic>? actionData,
    this.priority = NotificationPriority.medium,
    @TimestampConverter() required this.createdAt,
    this.read = false,
    @NullableTimestampConverter() this.readAt,
    @NullableTimestampConverter() this.expiresAt,
  }) : _data = data,
       _actionData = actionData,
       super._();

  @override
  final String notificationId;
  @override
  final NotificationType type;
  @override
  final String recipientUid;
  @override
  final String recipientProfileId;
  @override
  final String? senderUid;
  @override
  final String? senderProfileId;
  @override
  final String? senderName;
  @override
  final String? senderPhoto;
  @override
  final String title;
  @override
  final String message;
  final Map<String, dynamic> _data;
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  final NotificationActionType? actionType;
  final Map<String, dynamic>? _actionData;
  @override
  Map<String, dynamic>? get actionData {
    final value = _actionData;
    if (value == null) return null;
    if (_actionData is EqualUnmodifiableMapView) return _actionData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final NotificationPriority priority;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool read;
  @override
  @NullableTimestampConverter()
  final DateTime? readAt;
  @override
  @NullableTimestampConverter()
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'NotificationEntity(notificationId: $notificationId, type: $type, recipientUid: $recipientUid, recipientProfileId: $recipientProfileId, senderUid: $senderUid, senderProfileId: $senderProfileId, senderName: $senderName, senderPhoto: $senderPhoto, title: $title, message: $message, data: $data, actionType: $actionType, actionData: $actionData, priority: $priority, createdAt: $createdAt, read: $read, readAt: $readAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationEntityImpl &&
            (identical(other.notificationId, notificationId) ||
                other.notificationId == notificationId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.recipientUid, recipientUid) ||
                other.recipientUid == recipientUid) &&
            (identical(other.recipientProfileId, recipientProfileId) ||
                other.recipientProfileId == recipientProfileId) &&
            (identical(other.senderUid, senderUid) ||
                other.senderUid == senderUid) &&
            (identical(other.senderProfileId, senderProfileId) ||
                other.senderProfileId == senderProfileId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderPhoto, senderPhoto) ||
                other.senderPhoto == senderPhoto) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            const DeepCollectionEquality().equals(
              other._actionData,
              _actionData,
            ) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.read, read) || other.read == read) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    notificationId,
    type,
    recipientUid,
    recipientProfileId,
    senderUid,
    senderProfileId,
    senderName,
    senderPhoto,
    title,
    message,
    const DeepCollectionEquality().hash(_data),
    actionType,
    const DeepCollectionEquality().hash(_actionData),
    priority,
    createdAt,
    read,
    readAt,
    expiresAt,
  );

  /// Create a copy of NotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationEntityImplCopyWith<_$NotificationEntityImpl> get copyWith =>
      __$$NotificationEntityImplCopyWithImpl<_$NotificationEntityImpl>(
        this,
        _$identity,
      );
}

abstract class _NotificationEntity extends NotificationEntity {
  const factory _NotificationEntity({
    required final String notificationId,
    required final NotificationType type,
    required final String recipientUid,
    required final String recipientProfileId,
    final String? senderUid,
    final String? senderProfileId,
    final String? senderName,
    final String? senderPhoto,
    required final String title,
    required final String message,
    final Map<String, dynamic> data,
    final NotificationActionType? actionType,
    final Map<String, dynamic>? actionData,
    final NotificationPriority priority,
    @TimestampConverter() required final DateTime createdAt,
    final bool read,
    @NullableTimestampConverter() final DateTime? readAt,
    @NullableTimestampConverter() final DateTime? expiresAt,
  }) = _$NotificationEntityImpl;
  const _NotificationEntity._() : super._();

  @override
  String get notificationId;
  @override
  NotificationType get type;
  @override
  String get recipientUid;
  @override
  String get recipientProfileId;
  @override
  String? get senderUid;
  @override
  String? get senderProfileId;
  @override
  String? get senderName;
  @override
  String? get senderPhoto;
  @override
  String get title;
  @override
  String get message;
  @override
  Map<String, dynamic> get data;
  @override
  NotificationActionType? get actionType;
  @override
  Map<String, dynamic>? get actionData;
  @override
  NotificationPriority get priority;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  bool get read;
  @override
  @NullableTimestampConverter()
  DateTime? get readAt;
  @override
  @NullableTimestampConverter()
  DateTime? get expiresAt;

  /// Create a copy of NotificationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationEntityImplCopyWith<_$NotificationEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
