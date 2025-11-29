// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MessageEntity _$MessageEntityFromJson(Map<String, dynamic> json) {
  return _MessageEntity.fromJson(json);
}

/// @nodoc
mixin _$MessageEntity {
  String get messageId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError; // UID do remetente
  String get senderProfileId =>
      throw _privateConstructorUsedError; // ProfileId do remetente
  String get text => throw _privateConstructorUsedError; // Conteúdo da mensagem
  String? get imageUrl =>
      throw _privateConstructorUsedError; // URL da imagem (opcional)
  MessageReplyEntity? get replyTo =>
      throw _privateConstructorUsedError; // Mensagem sendo respondida
  Map<String, String> get reactions =>
      throw _privateConstructorUsedError; // uid: emoji
  @TimestampConverter()
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get read => throw _privateConstructorUsedError;

  /// Serializes this MessageEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageEntityCopyWith<MessageEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageEntityCopyWith<$Res> {
  factory $MessageEntityCopyWith(
    MessageEntity value,
    $Res Function(MessageEntity) then,
  ) = _$MessageEntityCopyWithImpl<$Res, MessageEntity>;
  @useResult
  $Res call({
    String messageId,
    String senderId,
    String senderProfileId,
    String text,
    String? imageUrl,
    MessageReplyEntity? replyTo,
    Map<String, String> reactions,
    @TimestampConverter() DateTime timestamp,
    bool read,
  });

  $MessageReplyEntityCopyWith<$Res>? get replyTo;
}

/// @nodoc
class _$MessageEntityCopyWithImpl<$Res, $Val extends MessageEntity>
    implements $MessageEntityCopyWith<$Res> {
  _$MessageEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? senderId = null,
    Object? senderProfileId = null,
    Object? text = null,
    Object? imageUrl = freezed,
    Object? replyTo = freezed,
    Object? reactions = null,
    Object? timestamp = null,
    Object? read = null,
  }) {
    return _then(
      _value.copyWith(
            messageId: null == messageId
                ? _value.messageId
                : messageId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderProfileId: null == senderProfileId
                ? _value.senderProfileId
                : senderProfileId // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            replyTo: freezed == replyTo
                ? _value.replyTo
                : replyTo // ignore: cast_nullable_to_non_nullable
                      as MessageReplyEntity?,
            reactions: null == reactions
                ? _value.reactions
                : reactions // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            read: null == read
                ? _value.read
                : read // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of MessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageReplyEntityCopyWith<$Res>? get replyTo {
    if (_value.replyTo == null) {
      return null;
    }

    return $MessageReplyEntityCopyWith<$Res>(_value.replyTo!, (value) {
      return _then(_value.copyWith(replyTo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageEntityImplCopyWith<$Res>
    implements $MessageEntityCopyWith<$Res> {
  factory _$$MessageEntityImplCopyWith(
    _$MessageEntityImpl value,
    $Res Function(_$MessageEntityImpl) then,
  ) = __$$MessageEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String messageId,
    String senderId,
    String senderProfileId,
    String text,
    String? imageUrl,
    MessageReplyEntity? replyTo,
    Map<String, String> reactions,
    @TimestampConverter() DateTime timestamp,
    bool read,
  });

  @override
  $MessageReplyEntityCopyWith<$Res>? get replyTo;
}

/// @nodoc
class __$$MessageEntityImplCopyWithImpl<$Res>
    extends _$MessageEntityCopyWithImpl<$Res, _$MessageEntityImpl>
    implements _$$MessageEntityImplCopyWith<$Res> {
  __$$MessageEntityImplCopyWithImpl(
    _$MessageEntityImpl _value,
    $Res Function(_$MessageEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? senderId = null,
    Object? senderProfileId = null,
    Object? text = null,
    Object? imageUrl = freezed,
    Object? replyTo = freezed,
    Object? reactions = null,
    Object? timestamp = null,
    Object? read = null,
  }) {
    return _then(
      _$MessageEntityImpl(
        messageId: null == messageId
            ? _value.messageId
            : messageId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderProfileId: null == senderProfileId
            ? _value.senderProfileId
            : senderProfileId // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        replyTo: freezed == replyTo
            ? _value.replyTo
            : replyTo // ignore: cast_nullable_to_non_nullable
                  as MessageReplyEntity?,
        reactions: null == reactions
            ? _value._reactions
            : reactions // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        read: null == read
            ? _value.read
            : read // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageEntityImpl extends _MessageEntity {
  const _$MessageEntityImpl({
    required this.messageId,
    required this.senderId,
    required this.senderProfileId,
    required this.text,
    this.imageUrl,
    this.replyTo,
    final Map<String, String> reactions = const {},
    @TimestampConverter() required this.timestamp,
    this.read = false,
  }) : _reactions = reactions,
       super._();

  factory _$MessageEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageEntityImplFromJson(json);

  @override
  final String messageId;
  @override
  final String senderId;
  // UID do remetente
  @override
  final String senderProfileId;
  // ProfileId do remetente
  @override
  final String text;
  // Conteúdo da mensagem
  @override
  final String? imageUrl;
  // URL da imagem (opcional)
  @override
  final MessageReplyEntity? replyTo;
  // Mensagem sendo respondida
  final Map<String, String> _reactions;
  // Mensagem sendo respondida
  @override
  @JsonKey()
  Map<String, String> get reactions {
    if (_reactions is EqualUnmodifiableMapView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_reactions);
  }

  // uid: emoji
  @override
  @TimestampConverter()
  final DateTime timestamp;
  @override
  @JsonKey()
  final bool read;

  @override
  String toString() {
    return 'MessageEntity(messageId: $messageId, senderId: $senderId, senderProfileId: $senderProfileId, text: $text, imageUrl: $imageUrl, replyTo: $replyTo, reactions: $reactions, timestamp: $timestamp, read: $read)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageEntityImpl &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderProfileId, senderProfileId) ||
                other.senderProfileId == senderProfileId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.replyTo, replyTo) || other.replyTo == replyTo) &&
            const DeepCollectionEquality().equals(
              other._reactions,
              _reactions,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.read, read) || other.read == read));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    messageId,
    senderId,
    senderProfileId,
    text,
    imageUrl,
    replyTo,
    const DeepCollectionEquality().hash(_reactions),
    timestamp,
    read,
  );

  /// Create a copy of MessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageEntityImplCopyWith<_$MessageEntityImpl> get copyWith =>
      __$$MessageEntityImplCopyWithImpl<_$MessageEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageEntityImplToJson(this);
  }
}

abstract class _MessageEntity extends MessageEntity {
  const factory _MessageEntity({
    required final String messageId,
    required final String senderId,
    required final String senderProfileId,
    required final String text,
    final String? imageUrl,
    final MessageReplyEntity? replyTo,
    final Map<String, String> reactions,
    @TimestampConverter() required final DateTime timestamp,
    final bool read,
  }) = _$MessageEntityImpl;
  const _MessageEntity._() : super._();

  factory _MessageEntity.fromJson(Map<String, dynamic> json) =
      _$MessageEntityImpl.fromJson;

  @override
  String get messageId;
  @override
  String get senderId; // UID do remetente
  @override
  String get senderProfileId; // ProfileId do remetente
  @override
  String get text; // Conteúdo da mensagem
  @override
  String? get imageUrl; // URL da imagem (opcional)
  @override
  MessageReplyEntity? get replyTo; // Mensagem sendo respondida
  @override
  Map<String, String> get reactions; // uid: emoji
  @override
  @TimestampConverter()
  DateTime get timestamp;
  @override
  bool get read;

  /// Create a copy of MessageEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageEntityImplCopyWith<_$MessageEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageReplyEntity _$MessageReplyEntityFromJson(Map<String, dynamic> json) {
  return _MessageReplyEntity.fromJson(json);
}

/// @nodoc
mixin _$MessageReplyEntity {
  String get messageId => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String? get senderProfileId => throw _privateConstructorUsedError;

  /// Serializes this MessageReplyEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageReplyEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageReplyEntityCopyWith<MessageReplyEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageReplyEntityCopyWith<$Res> {
  factory $MessageReplyEntityCopyWith(
    MessageReplyEntity value,
    $Res Function(MessageReplyEntity) then,
  ) = _$MessageReplyEntityCopyWithImpl<$Res, MessageReplyEntity>;
  @useResult
  $Res call({
    String messageId,
    String text,
    String senderId,
    String? senderProfileId,
  });
}

/// @nodoc
class _$MessageReplyEntityCopyWithImpl<$Res, $Val extends MessageReplyEntity>
    implements $MessageReplyEntityCopyWith<$Res> {
  _$MessageReplyEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageReplyEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? text = null,
    Object? senderId = null,
    Object? senderProfileId = freezed,
  }) {
    return _then(
      _value.copyWith(
            messageId: null == messageId
                ? _value.messageId
                : messageId // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
            senderProfileId: freezed == senderProfileId
                ? _value.senderProfileId
                : senderProfileId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageReplyEntityImplCopyWith<$Res>
    implements $MessageReplyEntityCopyWith<$Res> {
  factory _$$MessageReplyEntityImplCopyWith(
    _$MessageReplyEntityImpl value,
    $Res Function(_$MessageReplyEntityImpl) then,
  ) = __$$MessageReplyEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String messageId,
    String text,
    String senderId,
    String? senderProfileId,
  });
}

/// @nodoc
class __$$MessageReplyEntityImplCopyWithImpl<$Res>
    extends _$MessageReplyEntityCopyWithImpl<$Res, _$MessageReplyEntityImpl>
    implements _$$MessageReplyEntityImplCopyWith<$Res> {
  __$$MessageReplyEntityImplCopyWithImpl(
    _$MessageReplyEntityImpl _value,
    $Res Function(_$MessageReplyEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageReplyEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? text = null,
    Object? senderId = null,
    Object? senderProfileId = freezed,
  }) {
    return _then(
      _$MessageReplyEntityImpl(
        messageId: null == messageId
            ? _value.messageId
            : messageId // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
        senderProfileId: freezed == senderProfileId
            ? _value.senderProfileId
            : senderProfileId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageReplyEntityImpl extends _MessageReplyEntity {
  const _$MessageReplyEntityImpl({
    required this.messageId,
    required this.text,
    required this.senderId,
    this.senderProfileId,
  }) : super._();

  factory _$MessageReplyEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageReplyEntityImplFromJson(json);

  @override
  final String messageId;
  @override
  final String text;
  @override
  final String senderId;
  @override
  final String? senderProfileId;

  @override
  String toString() {
    return 'MessageReplyEntity(messageId: $messageId, text: $text, senderId: $senderId, senderProfileId: $senderProfileId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageReplyEntityImpl &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderProfileId, senderProfileId) ||
                other.senderProfileId == senderProfileId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, messageId, text, senderId, senderProfileId);

  /// Create a copy of MessageReplyEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageReplyEntityImplCopyWith<_$MessageReplyEntityImpl> get copyWith =>
      __$$MessageReplyEntityImplCopyWithImpl<_$MessageReplyEntityImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageReplyEntityImplToJson(this);
  }
}

abstract class _MessageReplyEntity extends MessageReplyEntity {
  const factory _MessageReplyEntity({
    required final String messageId,
    required final String text,
    required final String senderId,
    final String? senderProfileId,
  }) = _$MessageReplyEntityImpl;
  const _MessageReplyEntity._() : super._();

  factory _MessageReplyEntity.fromJson(Map<String, dynamic> json) =
      _$MessageReplyEntityImpl.fromJson;

  @override
  String get messageId;
  @override
  String get text;
  @override
  String get senderId;
  @override
  String? get senderProfileId;

  /// Create a copy of MessageReplyEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageReplyEntityImplCopyWith<_$MessageReplyEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
