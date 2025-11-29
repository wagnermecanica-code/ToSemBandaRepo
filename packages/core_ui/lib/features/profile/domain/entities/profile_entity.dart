import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

/// Profile Entity - Immutable profile representation
@immutable
class ProfileEntity {
  /// Creates a new ProfileEntity
  const ProfileEntity({
    required this.profileId,
    required this.uid,
    required this.name,
    required this.isBand,
    required this.city,
    required this.location,
    required this.createdAt,
    required this.notificationRadius,
    required this.notificationRadiusEnabled,
    this.photoUrl,
    this.birthYear,
    this.bio,
    this.instruments,
    this.genres,
    this.level,
    this.instagramLink,
    this.tiktokLink,
    this.youtubeLink,
    this.neighborhood,
    this.state,
    this.bandMembers,
    this.updatedAt,
  });

  /// Creates ProfileEntity from Firestore document
  factory ProfileEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;

    // Helper para converter Timestamp
    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }

    // Helper para converter GeoPoint
    GeoPoint parseGeoPoint(dynamic value) {
      if (value is GeoPoint) return value;
      if (value is Map) {
        final map = value as Map<String, dynamic>;
        if (map.containsKey('_latitude') && map.containsKey('_longitude')) {
          return GeoPoint(
            (map['_latitude'] as num).toDouble(),
            (map['_longitude'] as num).toDouble(),
          );
        }
        if (map.containsKey('latitude') && map.containsKey('longitude')) {
          return GeoPoint(
            (map['latitude'] as num).toDouble(),
            (map['longitude'] as num).toDouble(),
          );
        }
      }
      return const GeoPoint(0, 0);
    }

    return ProfileEntity(
      profileId: snapshot.id,
      uid: (data['uid'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      isBand: (data['isBand'] as bool?) ?? false,
      city: (data['city'] as String?) ?? '',
      location: parseGeoPoint(data['location']),
      createdAt: parseTimestamp(data['createdAt']),
      notificationRadius:
          (data['notificationRadius'] as num?)?.toDouble() ?? 20.0,
      notificationRadiusEnabled:
          (data['notificationRadiusEnabled'] as bool?) ?? true,
      photoUrl: data['photoUrl'] as String?,
      birthYear: data['birthYear'] as int?,
      bio: data['bio'] as String?,
      instruments: (data['instruments'] as List<dynamic>?)?.cast<String>(),
      genres: (data['genres'] as List<dynamic>?)?.cast<String>(),
      level: data['level'] as String?,
      instagramLink: data['instagramLink'] as String?,
      tiktokLink: data['tiktokLink'] as String?,
      youtubeLink: data['youtubeLink'] as String?,
      neighborhood: data['neighborhood'] as String?,
      state: data['state'] as String?,
      bandMembers: (data['bandMembers'] as List<dynamic>?)?.cast<String>(),
      updatedAt:
          data['updatedAt'] != null ? parseTimestamp(data['updatedAt']) : null,
    );
  }

  /// Creates ProfileEntity from JSON
  factory ProfileEntity.fromJson(Map<String, dynamic> json) {
    return ProfileEntity(
      profileId: json['profileId'] as String,
      uid: json['uid'] as String,
      name: json['name'] as String,
      isBand: json['isBand'] as bool,
      city: json['city'] as String,
      location: json['location'] is GeoPoint
          ? json['location'] as GeoPoint
          : GeoPoint(
              (json['location']['latitude'] as num).toDouble(),
              (json['location']['longitude'] as num).toDouble(),
            ),
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : (json['createdAt'] as Timestamp).toDate(),
      notificationRadius: (json['notificationRadius'] as num).toDouble(),
      notificationRadiusEnabled: json['notificationRadiusEnabled'] as bool,
      photoUrl: json['photoUrl'] as String?,
      birthYear: json['birthYear'] as int?,
      bio: json['bio'] as String?,
      instruments: (json['instruments'] as List<dynamic>?)?.cast<String>(),
      genres: (json['genres'] as List<dynamic>?)?.cast<String>(),
      level: json['level'] as String?,
      instagramLink: json['instagramLink'] as String?,
      tiktokLink: json['tiktokLink'] as String?,
      youtubeLink: json['youtubeLink'] as String?,
      neighborhood: json['neighborhood'] as String?,
      state: json['state'] as String?,
      bandMembers: (json['bandMembers'] as List<dynamic>?)?.cast<String>(),
      updatedAt: json['updatedAt'] is DateTime?
          ? json['updatedAt'] as DateTime?
          : (json['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Unique profile identifier
  final String profileId;

  /// Firebase Auth user ID
  final String uid;

  /// Profile display name
  final String name;

  /// Whether this is a band profile
  final bool isBand;

  /// City location
  final String city;

  /// Geographic location
  final GeoPoint location;

  /// Profile creation timestamp
  final DateTime createdAt;

  /// Notification radius in kilometers
  final double notificationRadius;

  /// Whether notification radius is enabled
  final bool notificationRadiusEnabled;

  /// Profile photo URL
  final String? photoUrl;

  /// Birth year
  final int? birthYear;

  /// Biography
  final String? bio;

  /// Musical instruments
  final List<String>? instruments;

  /// Musical genres
  final List<String>? genres;

  /// Skill level
  final String? level;

  /// Instagram profile link
  final String? instagramLink;

  /// TikTok profile link
  final String? tiktokLink;

  /// YouTube channel link
  final String? youtubeLink;

  /// Neighborhood
  final String? neighborhood;

  /// State
  final String? state;

  /// Band members list
  final List<String>? bandMembers;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Converts ProfileEntity to JSON
  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'uid': uid,
      'name': name,
      'isBand': isBand,
      'city': city,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'notificationRadius': notificationRadius,
      'notificationRadiusEnabled': notificationRadiusEnabled,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (birthYear != null) 'birthYear': birthYear,
      if (bio != null) 'bio': bio,
      if (instruments != null) 'instruments': instruments,
      if (genres != null) 'genres': genres,
      if (level != null) 'level': level,
      if (instagramLink != null) 'instagramLink': instagramLink,
      if (tiktokLink != null) 'tiktokLink': tiktokLink,
      if (youtubeLink != null) 'youtubeLink': youtubeLink,
      if (neighborhood != null) 'neighborhood': neighborhood,
      if (state != null) 'state': state,
      if (bandMembers != null) 'bandMembers': bandMembers,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Converts ProfileEntity to Firestore map (without profileId)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('profileId'); // ID vai no documento, não no data
    return json;
  }

  /// Versão resumida para array em users/{uid}.profiles
  Map<String, dynamic> toSummary() {
    return {
      'profileId': profileId,
      'name': name,
      'photoUrl': photoUrl,
      'type': isBand ? 'band' : 'musician',
      'city': city,
    };
  }

  /// Creates a copy with modified fields
  ProfileEntity copyWith({
    String? profileId,
    String? uid,
    String? name,
    bool? isBand,
    String? city,
    GeoPoint? location,
    DateTime? createdAt,
    double? notificationRadius,
    bool? notificationRadiusEnabled,
    String? photoUrl,
    int? birthYear,
    String? bio,
    List<String>? instruments,
    List<String>? genres,
    String? level,
    String? instagramLink,
    String? tiktokLink,
    String? youtubeLink,
    String? neighborhood,
    String? state,
    List<String>? bandMembers,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      profileId: profileId ?? this.profileId,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      isBand: isBand ?? this.isBand,
      city: city ?? this.city,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      notificationRadius: notificationRadius ?? this.notificationRadius,
      notificationRadiusEnabled:
          notificationRadiusEnabled ?? this.notificationRadiusEnabled,
      photoUrl: photoUrl ?? this.photoUrl,
      birthYear: birthYear ?? this.birthYear,
      bio: bio ?? this.bio,
      instruments: instruments ?? this.instruments,
      genres: genres ?? this.genres,
      level: level ?? this.level,
      instagramLink: instagramLink ?? this.instagramLink,
      tiktokLink: tiktokLink ?? this.tiktokLink,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      neighborhood: neighborhood ?? this.neighborhood,
      state: state ?? this.state,
      bandMembers: bandMembers ?? this.bandMembers,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileEntity &&
          runtimeType == other.runtimeType &&
          profileId == other.profileId &&
          uid == other.uid;

  @override
  int get hashCode => profileId.hashCode ^ uid.hashCode;

  int? get age {
    if (birthYear == null) return null;
    return DateTime.now().year - birthYear!;
  }

  String get ageLabel => isBand ? 'Tempo de formação' : 'Idade';

  /// Calcula idade (músicos) ou tempo de formação (bandas) em anos
  int? get ageOrYearsSinceFormation {
    if (birthYear == null) return null;
    return DateTime.now().year - birthYear!;
  }

  /// Texto formatado: "25 anos" ou "5 anos de formação"
  String? get ageOrFormationText {
    final years = ageOrYearsSinceFormation;
    if (years == null) return null;
    if (isBand) {
      return years == 1 ? '$years ano de formação' : '$years anos de formação';
    } else {
      return years == 1 ? '$years ano' : '$years anos';
    }
  }

  double get latitude => location.latitude;
  double get longitude => location.longitude;
}
