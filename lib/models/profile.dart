import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Modelo de perfil (músico ou banda) armazenado em profiles/{profileId}
/// Cada perfil age como um usuário independente no app
class Profile {
  final String profileId;
  final String uid; // Dono da conta Firebase Auth
  final String name;
  final bool isBand;
  final String? photoUrl;
  final String city;
  final GeoPoint location; // Obrigatório para geosearch
  final List<String> instruments;
  final List<String> genres;
  final String? level;
  final int? age;
  final String? bio;
  final String? youtubeLink;
  final String? neighborhood;
  final String? state;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Profile({
    String? profileId,
    required this.uid,
    required this.name,
    required this.isBand,
    this.photoUrl,
    required this.city,
    required this.location,
    List<String>? instruments,
    List<String>? genres,
    this.level,
    this.age,
    this.bio,
    this.youtubeLink,
    this.neighborhood,
    this.state,
    DateTime? createdAt,
    this.updatedAt,
  })  : profileId = profileId ?? const Uuid().v4(),
        instruments = instruments ?? [],
        genres = genres ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Cria Profile a partir de Map do Firestore
  factory Profile.fromMap(Map<String, dynamic> map, String profileId) {
    return Profile(
      profileId: profileId,
      uid: map['uid'] as String,
      name: map['name'] as String? ?? '',
      isBand: map['isBand'] as bool? ?? false,
      photoUrl: map['photoUrl'] as String?,
      city: map['city'] as String? ?? '',
      location: map['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      instruments: (map['instruments'] as List<dynamic>?)?.cast<String>() ?? [],
      genres: (map['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      level: map['level'] as String?,
      age: map['age'] as int?,
      bio: map['bio'] as String?,
      youtubeLink: map['youtubeLink'] as String?,
      neighborhood: map['neighborhood'] as String?,
      state: map['state'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converte Profile para Map do Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'isBand': isBand,
      'photoUrl': photoUrl,
      'city': city,
      'location': location,
      'instruments': instruments,
      'genres': genres,
      'level': level,
      'age': age,
      'bio': bio,
      'youtubeLink': youtubeLink,
      'neighborhood': neighborhood,
      'state': state,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
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

  /// Cria cópia com campos atualizados
  Profile copyWith({
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
    int? age,
    String? bio,
    String? youtubeLink,
    String? neighborhood,
    String? state,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
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
      age: age ?? this.age,
      bio: bio ?? this.bio,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      neighborhood: neighborhood ?? this.neighborhood,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converte latitude/longitude para GeoPoint
  static GeoPoint createGeoPoint(double latitude, double longitude) {
    return GeoPoint(latitude, longitude);
  }

  /// Extrai latitude do GeoPoint
  double get latitude => location.latitude;

  /// Extrai longitude do GeoPoint
  double get longitude => location.longitude;
}
