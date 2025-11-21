import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo do documento users/{uid} - dados mínimos da conta Firebase Auth
class AppUser {
  final String uid;
  final String? email;
  final String activeProfileId; // ID do perfil atualmente ativo
  final List<ProfileSummary> profiles; // Lista resumida para o switcher
  final DateTime createdAt;

  AppUser({
    required this.uid,
    this.email,
    required this.activeProfileId,
    List<ProfileSummary>? profiles,
    DateTime? createdAt,
  })  : profiles = profiles ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Cria AppUser a partir de Map do Firestore
  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] as String?,
      activeProfileId: map['activeProfileId'] as String? ?? uid,
      profiles: (map['profiles'] as List<dynamic>?)
              ?.map((p) => ProfileSummary.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converte AppUser para Map do Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'activeProfileId': activeProfileId,
      'profiles': profiles.map((p) => p.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Cria cópia com campos atualizados
  AppUser copyWith({
    String? uid,
    String? email,
    String? activeProfileId,
    List<ProfileSummary>? profiles,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      activeProfileId: activeProfileId ?? this.activeProfileId,
      profiles: profiles ?? this.profiles,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Versão resumida de perfil para armazenar em users/{uid}.profiles
class ProfileSummary {
  final String profileId;
  final String name;
  final String? photoUrl;
  final String type; // "musician" | "band"
  final String city;

  ProfileSummary({
    required this.profileId,
    required this.name,
    this.photoUrl,
    required this.type,
    required this.city,
  });

  factory ProfileSummary.fromMap(Map<String, dynamic> map) {
    return ProfileSummary(
      profileId: map['profileId'] as String,
      name: map['name'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      type: map['type'] as String? ?? 'musician',
      city: map['city'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'name': name,
      'photoUrl': photoUrl,
      'type': type,
      'city': city,
    };
  }

  bool get isBand => type == 'band';
  bool get isMusician => type == 'musician';
}
