import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'post_entity.freezed.dart';
part 'post_entity.g.dart';

/// Domain entity para Posts
/// Representa um post de músico ou banda procurando colaboradores
@freezed
class PostEntity with _$PostEntity {
  const factory PostEntity({
    required String id,
    required String authorProfileId,
    required String authorUid,
    required String content, // 'message' in old code
    @GeoPointConverter() required GeoPoint location,
    required String city,
    String? neighborhood,
    String? state,
    String? photoUrl,
    String? youtubeLink,
    required String type, // 'band' or 'musician'
    required String level,
    required List<String> instruments,
    required List<String> genres,
    required List<String> seekingMusicians,
    @Default([]) List<String> availableFor,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime expiresAt, // 30 days after creation
    double? distanceKm, // Calculated field, not stored in Firestore
  }) = _PostEntity;

  const PostEntity._();

  /// Getters úteis
  double get latitude => location.latitude;
  double get longitude => location.longitude;
  
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
  bool get hasYouTube => youtubeLink != null && youtubeLink!.isNotEmpty;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  /// From Firestore Document
  factory PostEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Post data is null');
    }

    return PostEntity(
      id: snapshot.id,
      authorProfileId: data['authorProfileId'] as String? ?? '',
      authorUid: data['authorUid'] as String? ?? '',
      content: (data['content'] ?? data['message']) as String? ?? '',
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      city: data['city'] as String? ?? '',
      neighborhood: data['neighborhood'] as String?,
      state: data['state'] as String?,
      photoUrl: data['photoUrl'] as String?,
      youtubeLink: data['youtubeLink'] as String?,
      type: data['type'] as String? ?? 'musician',
      level: data['level'] as String? ?? '',
      instruments: List<String>.from(data['instruments'] ?? []),
      genres: List<String>.from(data['genres'] ?? []),
      seekingMusicians: List<String>.from(data['seekingMusicians'] ?? []),
      availableFor: List<String>.from(data['availableFor'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? 
        DateTime.now().add(const Duration(days: 30)),
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
    );
  }

  /// To Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'authorProfileId': authorProfileId,
      'authorUid': authorUid,
      'content': content,
      'location': location,
      'city': city,
      if (neighborhood != null) 'neighborhood': neighborhood,
      if (state != null) 'state': state,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (youtubeLink != null) 'youtubeLink': youtubeLink,
      'type': type,
      'level': level,
      'instruments': instruments,
      'genres': genres,
      'seekingMusicians': seekingMusicians,
      'availableFor': availableFor,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  /// To legacy Post model (for backward compatibility)
  factory PostEntity.fromJson(Map<String, dynamic> json) => 
    _$PostEntityFromJson(json);
}

/// Custom converter for GeoPoint
class GeoPointConverter implements JsonConverter<GeoPoint, Map<String, dynamic>> {
  const GeoPointConverter();

  @override
  GeoPoint fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      (json['_latitude'] as num).toDouble(),
      (json['_longitude'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(GeoPoint geoPoint) {
    return {
      '_latitude': geoPoint.latitude,
      '_longitude': geoPoint.longitude,
    };
  }
}

/// Custom converter for Timestamp
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
}
