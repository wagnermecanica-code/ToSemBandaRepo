import 'package:cloud_firestore/cloud_firestore.dart';

/// ProfileEntity - Domain entity manual implementation
/// 
/// Representa um perfil (músico ou banda) no sistema multi-perfil.
/// Cada perfil age como identidade independente com dados isolados.
class ProfileEntity {
  const ProfileEntity({
    required this.profileId,
    required this.uid,
    required this.name,
    required this.isBand,
    this.photoUrl,
    required this.city,
    required this.location,
    this.instruments = const [],
    this.genres = const [],
    this.level,
    this.birthYear,
    this.bio,
    this.youtubeLink,
    this.instagramLink,
    this.tiktokLink,
    this.bandMembers = const [],
    this.neighborhood,
    this.state,
    this.notificationRadiusEnabled = true,
    this.notificationRadius = 20.0,
    required this.createdAt,
    this.updatedAt,
  });
  
  final String profileId;
  final String uid; // Dono da conta Firebase Auth
  final String name;
  final bool isBand;
  final String? photoUrl;
  final String city;
  final GeoPoint location;
  final List<String> instruments;
  final List<String> genres;
  final String? level;
  final int? birthYear; // Ano de nascimento (músicos) ou formação (bandas)
  final String? bio;
  final String? youtubeLink;
  final String? instagramLink;
  final String? tiktokLink;
  final List<String> bandMembers;
  final String? neighborhood;
  final String? state;
  final bool notificationRadiusEnabled;
  final double notificationRadius;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  /// copyWith method
  ProfileEntity copyWith({
    String? profileId,
    String? uid,
    String? name,
    bool? isBand,
    String? photoUrl,
    String? city,
    GeoPoint? location,
    List<String>? instruments,
    List<String>? genres,
    String? level,
    int? birthYear,
    String? bio,
    String? youtubeLink,
    String? instagramLink,
    String? tiktokLink,
    List<String>? bandMembers,
    String? neighborhood,
    String? state,
    bool? notificationRadiusEnabled,
    double? notificationRadius,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      profileId: profileId ?? this.profileId,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      isBand: isBand ?? this.isBand,
      photoUrl: photoUrl ?? this.photoUrl,
      city: city ?? this.city,
      location: location ?? this.location,
      instruments: instruments ?? this.instruments,
      genres: genres ?? this.genres,
      level: level ?? this.level,
      birthYear: birthYear ?? this.birthYear,
      bio: bio ?? this.bio,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      instagramLink: instagramLink ?? this.instagramLink,
      tiktokLink: tiktokLink ?? this.tiktokLink,
      bandMembers: bandMembers ?? this.bandMembers,
      neighborhood: neighborhood ?? this.neighborhood,
      state: state ?? this.state,
      notificationRadiusEnabled: notificationRadiusEnabled ?? this.notificationRadiusEnabled,
      notificationRadius: notificationRadius ?? this.notificationRadius,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Equality based on profileId
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileEntity &&
          runtimeType == other.runtimeType &&
          profileId == other.profileId;
  
  @override
  int get hashCode => profileId.hashCode;
  
  @override
  String toString() {
    return 'ProfileEntity(profileId: $profileId, uid: $uid, name: $name, isBand: $isBand, city: $city)';
  }
  
  /// Factory para criar a partir do Firestore
  factory ProfileEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final Map<String, dynamic> data = snapshot.data()!;
    
    // Helper para converter Timestamp
    DateTime _parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }
    
    // Helper para converter GeoPoint
    GeoPoint _parseGeoPoint(dynamic value) {
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
      photoUrl: data['photoUrl'] as String?,
      city: (data['city'] as String?) ?? '',
      location: _parseGeoPoint(data['location']),
      instruments: (data['instruments'] as List<dynamic>?)?.cast<String>() ?? [],
      genres: (data['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      level: data['level'] as String?,
      birthYear: data['birthYear'] as int?,
      bio: data['bio'] as String?,
      youtubeLink: data['youtubeLink'] as String?,
      instagramLink: data['instagramLink'] as String?,
      tiktokLink: data['tiktokLink'] as String?,
      bandMembers: (data['bandMembers'] as List<dynamic>?)?.cast<String>() ?? [],
      neighborhood: data['neighborhood'] as String?,
      state: data['state'] as String?,
      notificationRadiusEnabled: (data['notificationRadiusEnabled'] as bool?) ?? true,
      notificationRadius: (data['notificationRadius'] as num?)?.toDouble() ?? 20.0,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: data['updatedAt'] != null ? _parseTimestamp(data['updatedAt']) : null,
    );
  }
  
  /// Factory para criar a partir de JSON
  factory ProfileEntity.fromJson(Map<String, dynamic> json) {
    // Helper para converter Timestamp
    DateTime _parseTimestamp(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }
    
    // Helper para converter GeoPoint
    GeoPoint _parseGeoPoint(dynamic value) {
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
      profileId: (json['profileId'] as String?) ?? '',
      uid: (json['uid'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      isBand: (json['isBand'] as bool?) ?? false,
      photoUrl: json['photoUrl'] as String?,
      city: (json['city'] as String?) ?? '',
      location: _parseGeoPoint(json['location']),
      instruments: (json['instruments'] as List<dynamic>?)?.cast<String>() ?? [],
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      level: json['level'] as String?,
      birthYear: json['birthYear'] as int?,
      bio: json['bio'] as String?,
      youtubeLink: json['youtubeLink'] as String?,
      instagramLink: json['instagramLink'] as String?,
      tiktokLink: json['tiktokLink'] as String?,
      bandMembers: (json['bandMembers'] as List<dynamic>?)?.cast<String>() ?? [],
      neighborhood: json['neighborhood'] as String?,
      state: json['state'] as String?,
      notificationRadiusEnabled: (json['notificationRadiusEnabled'] as bool?) ?? true,
      notificationRadius: (json['notificationRadius'] as num?)?.toDouble() ?? 20.0,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? _parseTimestamp(json['updatedAt']) : null,
    );
  }
  
  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'uid': uid,
      'name': name,
      'isBand': isBand,
      'photoUrl': photoUrl,
      'city': city,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'instruments': instruments,
      'genres': genres,
      'level': level,
      'birthYear': birthYear,
      'bio': bio,
      'youtubeLink': youtubeLink,
      'instagramLink': instagramLink,
      'tiktokLink': tiktokLink,
      'bandMembers': bandMembers,
      'neighborhood': neighborhood,
      'state': state,
      'notificationRadiusEnabled': notificationRadiusEnabled,
      'notificationRadius': notificationRadius,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
  
  /// Converte para Map do Firestore (sem profileId)
  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> json = toJson();
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
  
  /// Getters úteis
  double get latitude => location.latitude;
  double get longitude => location.longitude;
  
  /// Calcula idade (músicos) ou tempo de formação (bandas) em anos
  int? get ageOrYearsSinceFormation {
    if (birthYear == null) return null;
    return DateTime.now().year - birthYear!;
  }
  
  /// Label contextual: "Idade" para músicos, "Tempo de formação" para bandas
  String get ageLabel => isBand ? 'Tempo de formação' : 'Idade';
  
  /// Texto formatado: "25 anos" ou "5 anos de formação"
  String? get ageOrFormationText {
    final int? years = ageOrYearsSinceFormation;
    if (years == null) return null;
    if (isBand) {
      return years == 1 ? '$years ano de formação' : '$years anos de formação';
    } else {
      return years == 1 ? '$years ano' : '$years anos';
    }
  }
}
