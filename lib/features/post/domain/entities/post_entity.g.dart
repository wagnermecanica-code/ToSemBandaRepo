// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostEntityImpl _$$PostEntityImplFromJson(Map<String, dynamic> json) =>
    _$PostEntityImpl(
      id: json['id'] as String,
      authorProfileId: json['authorProfileId'] as String,
      authorUid: json['authorUid'] as String,
      content: json['content'] as String,
      location: const GeoPointConverter().fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      city: json['city'] as String,
      neighborhood: json['neighborhood'] as String?,
      state: json['state'] as String?,
      photoUrl: json['photoUrl'] as String?,
      youtubeLink: json['youtubeLink'] as String?,
      type: json['type'] as String,
      level: json['level'] as String,
      instruments: (json['instruments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      genres: (json['genres'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      seekingMusicians: (json['seekingMusicians'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      availableFor:
          (json['availableFor'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Timestamp,
      ),
      expiresAt: const TimestampConverter().fromJson(
        json['expiresAt'] as Timestamp,
      ),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PostEntityImplToJson(_$PostEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorProfileId': instance.authorProfileId,
      'authorUid': instance.authorUid,
      'content': instance.content,
      'location': const GeoPointConverter().toJson(instance.location),
      'city': instance.city,
      'neighborhood': instance.neighborhood,
      'state': instance.state,
      'photoUrl': instance.photoUrl,
      'youtubeLink': instance.youtubeLink,
      'type': instance.type,
      'level': instance.level,
      'instruments': instance.instruments,
      'genres': instance.genres,
      'seekingMusicians': instance.seekingMusicians,
      'availableFor': instance.availableFor,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'expiresAt': const TimestampConverter().toJson(instance.expiresAt),
      'distanceKm': instance.distanceKm,
    };
