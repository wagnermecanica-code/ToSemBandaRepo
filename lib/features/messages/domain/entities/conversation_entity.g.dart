// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationEntityImpl _$$ConversationEntityImplFromJson(
  Map<String, dynamic> json,
) => _$ConversationEntityImpl(
  id: json['id'] as String,
  participants: (json['participants'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  participantProfiles: (json['participantProfiles'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lastMessage: json['lastMessage'] as String,
  lastMessageTimestamp: const TimestampConverter().fromJson(
    json['lastMessageTimestamp'] as Timestamp,
  ),
  unreadCount: Map<String, int>.from(json['unreadCount'] as Map),
  archived: json['archived'] as bool? ?? false,
  createdAt: const TimestampConverter().fromJson(
    json['createdAt'] as Timestamp,
  ),
  updatedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['updatedAt'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$$ConversationEntityImplToJson(
  _$ConversationEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'participants': instance.participants,
  'participantProfiles': instance.participantProfiles,
  'lastMessage': instance.lastMessage,
  'lastMessageTimestamp': const TimestampConverter().toJson(
    instance.lastMessageTimestamp,
  ),
  'unreadCount': instance.unreadCount,
  'archived': instance.archived,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': _$JsonConverterToJson<Timestamp, DateTime>(
    instance.updatedAt,
    const TimestampConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
