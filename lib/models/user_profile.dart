import 'package:uuid/uuid.dart';

/// Modelo de dados para um perfil de usuário (músico ou banda)
/// Permite que um usuário tenha múltiplos perfis
class UserProfile {
  final String profileId;
  final String name;
  final bool isBand;
  final String? photoUrl;
  final List<String> instruments;
  final List<String> genres;
  final String? bio;
  final String? youtubeLink;
  final String? level;
  final String? city;
  final String? neighborhood;
  final String? state;
  final double? latitude;
  final double? longitude;
  final bool notificationRadiusEnabled;
  final double notificationRadiusKm;

  UserProfile({
    String? profileId,
    required this.name,
    required this.isBand,
    this.photoUrl,
    List<String>? instruments,
    List<String>? genres,
    this.bio,
    this.youtubeLink,
    this.level,
    this.city,
    this.neighborhood,
    this.state,
    this.latitude,
    this.longitude,
    bool? notificationRadiusEnabled,
    double? notificationRadiusKm,
  })  : profileId = profileId ?? const Uuid().v4(),
        instruments = instruments ?? [],
        genres = genres ?? [],
        notificationRadiusEnabled = notificationRadiusEnabled ?? true,
        notificationRadiusKm = notificationRadiusKm ?? 20.0;

  /// Cria um UserProfile a partir de um Map (Firestore)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      profileId: map['profileId'] as String,
      name: map['name'] as String? ?? '',
      isBand: map['isBand'] as bool? ?? false,
      photoUrl: map['photoUrl'] as String?,
      instruments: (map['instruments'] as List<dynamic>?)?.cast<String>() ?? [],
      genres: (map['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      bio: map['bio'] as String?,
      youtubeLink: map['youtubeLink'] as String?,
      level: map['level'] as String?,
      city: map['city'] as String?,
      neighborhood: map['neighborhood'] as String?,
      state: map['state'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      notificationRadiusEnabled: map['notificationRadiusEnabled'] as bool?,
      notificationRadiusKm: map['notificationRadiusKm'] as double?,
    );
  }

  /// Converte UserProfile para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'name': name,
      'isBand': isBand,
      'photoUrl': photoUrl,
      'instruments': instruments,
      'genres': genres,
      'bio': bio,
      'youtubeLink': youtubeLink,
      'level': level,
      'city': city,
      'neighborhood': neighborhood,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'notificationRadiusEnabled': notificationRadiusEnabled,
      'notificationRadiusKm': notificationRadiusKm,
    };
  }

  /// Cria uma cópia do perfil com campos atualizados
  UserProfile copyWith({
    String? profileId,
    String? name,
    bool? isBand,
    String? photoUrl,
    List<String>? instruments,
    List<String>? genres,
    String? bio,
    String? youtubeLink,
    String? level,
    String? city,
    String? neighborhood,
    String? state,
    double? latitude,
    double? longitude,
    bool? notificationRadiusEnabled,
    double? notificationRadiusKm,
  }) {
    return UserProfile(
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      isBand: isBand ?? this.isBand,
      photoUrl: photoUrl ?? this.photoUrl,
      instruments: instruments ?? this.instruments,
      genres: genres ?? this.genres,
      bio: bio ?? this.bio,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      level: level ?? this.level,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notificationRadiusEnabled: notificationRadiusEnabled ?? this.notificationRadiusEnabled,
      notificationRadiusKm: notificationRadiusKm ?? this.notificationRadiusKm,
    );
  }
}
