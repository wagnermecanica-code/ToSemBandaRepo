import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain entity para Posts
/// Representa um post de músico ou banda procurando colaboradores
class PostEntity {
  // Calculated field, not stored in Firestore

  const PostEntity({
    required this.id,
    required this.authorProfileId,
    required this.authorUid,
    required this.content,
    required this.location,
    required this.city,
    required this.type,
    required this.level,
    required this.instruments,
    required this.genres,
    required this.seekingMusicians,
    required this.createdAt,
    required this.expiresAt,
    this.neighborhood,
    this.state,
    this.photoUrl,
    this.youtubeLink,
    this.availableFor = const [],
    this.distanceKm,
  });

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
      instruments:
          (data['instruments'] as List<dynamic>?)?.cast<String>() ?? [],
      genres: (data['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      seekingMusicians:
          (data['seekingMusicians'] as List<dynamic>?)?.cast<String>() ?? [],
      availableFor:
          (data['availableFor'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
    );
  }

  /// From JSON
  factory PostEntity.fromJson(Map<String, dynamic> json) {
    return PostEntity(
      id: json['id'] as String? ?? '',
      authorProfileId: json['authorProfileId'] as String? ?? '',
      authorUid: json['authorUid'] as String? ?? '',
      content: (json['content'] ?? json['message']) as String? ?? '',
      location: json['location'] != null
          ? GeoPoint(
              (json['location']['_latitude'] as num).toDouble(),
              (json['location']['_longitude'] as num).toDouble(),
            )
          : const GeoPoint(0, 0),
      city: json['city'] as String? ?? '',
      neighborhood: json['neighborhood'] as String?,
      state: json['state'] as String?,
      photoUrl: json['photoUrl'] as String?,
      youtubeLink: json['youtubeLink'] as String?,
      type: json['type'] as String? ?? 'musician',
      level: json['level'] as String? ?? '',
      instruments:
          (json['instruments'] as List<dynamic>?)?.cast<String>() ?? [],
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      seekingMusicians:
          (json['seekingMusicians'] as List<dynamic>?)?.cast<String>() ?? [],
      availableFor:
          (json['availableFor'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    );
  }
  final String id;
  final String authorProfileId;
  final String authorUid;
  final String content; // 'message' in old code
  final GeoPoint location;
  final String city;
  final String? neighborhood;
  final String? state;
  final String? photoUrl;
  final String? youtubeLink;
  final String type; // 'band' or 'musician'
  final String level;
  final List<String> instruments;
  final List<String> genres;
  final List<String> seekingMusicians;
  final List<String> availableFor;
  final DateTime createdAt;
  final DateTime expiresAt; // 30 days after creation
  final double? distanceKm;

  /// Getters úteis
  double get latitude => location.latitude;
  double get longitude => location.longitude;

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
  bool get hasYouTube => youtubeLink != null && youtubeLink!.isNotEmpty;
  bool get isExpired => DateTime.now().isAfter(expiresAt);

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

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorProfileId': authorProfileId,
      'authorUid': authorUid,
      'content': content,
      'location': {
        '_latitude': location.latitude,
        '_longitude': location.longitude,
      },
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
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      if (distanceKm != null) 'distanceKm': distanceKm,
    };
  }

  /// CopyWith
  PostEntity copyWith({
    String? id,
    String? authorProfileId,
    String? authorUid,
    String? content,
    GeoPoint? location,
    String? city,
    String? neighborhood,
    String? state,
    String? photoUrl,
    String? youtubeLink,
    String? type,
    String? level,
    List<String>? instruments,
    List<String>? genres,
    List<String>? seekingMusicians,
    List<String>? availableFor,
    DateTime? createdAt,
    DateTime? expiresAt,
    double? distanceKm,
  }) {
    return PostEntity(
      id: id ?? this.id,
      authorProfileId: authorProfileId ?? this.authorProfileId,
      authorUid: authorUid ?? this.authorUid,
      content: content ?? this.content,
      location: location ?? this.location,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      state: state ?? this.state,
      photoUrl: photoUrl ?? this.photoUrl,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      type: type ?? this.type,
      level: level ?? this.level,
      instruments: instruments ?? this.instruments,
      genres: genres ?? this.genres,
      seekingMusicians: seekingMusicians ?? this.seekingMusicians,
      availableFor: availableFor ?? this.availableFor,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PostEntity(id: $id, type: $type, city: $city)';
}
