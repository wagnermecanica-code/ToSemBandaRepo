// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageEntityImpl _$$MessageEntityImplFromJson(Map<String, dynamic> json) =>
    _$MessageEntityImpl(
      messageId: json['messageId'] as String,
      senderId: json['senderId'] as String,
      senderProfileId: json['senderProfileId'] as String,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      replyTo: json['replyTo'] == null
          ? null
          : MessageReplyEntity.fromJson(
              json['replyTo'] as Map<String, dynamic>,
            ),
      reactions:
          (json['reactions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      timestamp: const TimestampConverter().fromJson(
        json['timestamp'] as Timestamp,
      ),
      read: json['read'] as bool? ?? false,
    );

Map<String, dynamic> _$$MessageEntityImplToJson(_$MessageEntityImpl instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'senderId': instance.senderId,
      'senderProfileId': instance.senderProfileId,
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'replyTo': instance.replyTo,
      'reactions': instance.reactions,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'read': instance.read,
    };

_$MessageReplyEntityImpl _$$MessageReplyEntityImplFromJson(
  Map<String, dynamic> json,
) => _$MessageReplyEntityImpl(
  messageId: json['messageId'] as String,
  text: json['text'] as String,
  senderId: json['senderId'] as String,
  senderProfileId: json['senderProfileId'] as String?,
);

Map<String, dynamic> _$$MessageReplyEntityImplToJson(
  _$MessageReplyEntityImpl instance,
) => <String, dynamic>{
  'messageId': instance.messageId,
  'text': instance.text,
  'senderId': instance.senderId,
  'senderProfileId': instance.senderProfileId,
};
