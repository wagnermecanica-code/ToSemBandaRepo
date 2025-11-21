import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Post {
  final String id;
  final String authorProfileId;
  final String authorUid;
  final String content; // 'message' in old code
  final DateTime createdAt;
  final String type; // 'band' or 'musician'
  final LatLng? location;
  final String city;
  final String? photoUrl;
  final String? youtubeLink;
  final String level;
  final List<String> instruments;
  final List<String> genres;
  final List<String> seekingMusicians;
  final double? distanceKm; // Calculated field, not from Firestore

  Post({
    required this.id,
    required this.authorProfileId,
    required this.authorUid,
    required this.content,
    required this.createdAt,
    required this.type,
    this.location,
    required this.city,
    this.photoUrl,
    this.youtubeLink,
    required this.level,
    required this.instruments,
    required this.genres,
    required this.seekingMusicians,
    this.distanceKm,
  });

  factory Post.fromMap(Map<String, dynamic> data, String documentId) {
    final GeoPoint? point = data['location'];
    LatLng? location;
    if (point != null) {
      location = LatLng(point.latitude, point.longitude);
    }

    return Post(
      id: documentId,
      authorProfileId: data['authorProfileId'] ?? '',
      authorUid: data['authorUid'] ?? '',
      content: data['message'] ?? '', // Legacy support for 'message'
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      type: data['type'] ?? 'musician',
      location: location,
      city: data['city'] ?? '',
      photoUrl: data['photoUrl'],
      youtubeLink: data['youtubeLink'],
      level: data['level'] ?? '',
      instruments: List<String>.from(data['instruments'] ?? []),
      genres: List<String>.from(data['genres'] ?? []),
      seekingMusicians: List<String>.from(data['seekingMusicians'] ?? []),
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorProfileId': authorProfileId,
      'authorUid': authorUid,
      'message': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type,
      'location': location != null ? GeoPoint(location!.latitude, location!.longitude) : null,
      'city': city,
      'photoUrl': photoUrl,
      'youtubeLink': youtubeLink,
      'level': level,
      'instruments': instruments,
      'genres': genres,
      'seekingMusicians': seekingMusicians,
    };
  }

  Post copyWith({
    String? id,
    String? authorProfileId,
    String? authorUid,
    String? content,
    DateTime? createdAt,
    String? type,
    LatLng? location,
    String? city,
    String? photoUrl,
    String? youtubeLink,
    String? level,
    List<String>? instruments,
    List<String>? genres,
    List<String>? seekingMusicians,
    double? distanceKm,
  }) {
    return Post(
      id: id ?? this.id,
      authorProfileId: authorProfileId ?? this.authorProfileId,
      authorUid: authorUid ?? this.authorUid,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      location: location ?? this.location,
      city: city ?? this.city,
      photoUrl: photoUrl ?? this.photoUrl,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      level: level ?? this.level,
      instruments: instruments ?? this.instruments,
      genres: genres ?? this.genres,
      seekingMusicians: seekingMusicians ?? this.seekingMusicians,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}