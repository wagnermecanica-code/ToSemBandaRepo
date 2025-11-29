import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain entity para Conversas (chat 1:1)
/// Suporta multi-perfil: cada perfil pode ter conversas independentes
class ConversationEntity {
  const ConversationEntity({
    required this.id,
    required this.participants,
    required this.participantProfiles,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.unreadCount,
    required this.createdAt,
    this.participantProfilesData = const [],
    this.archived = false,
    this.updatedAt,
  });

  /// From Firestore Document
  /// Optional [profilesData] can be provided to enrich entity with full profile info
  factory ConversationEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    List<Map<String, dynamic>>? profilesData,
  }) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Conversation data is null');
    }

    return ConversationEntity(
      id: snapshot.id,
      participants:
          (data['participants'] as List<dynamic>?)?.cast<String>() ?? [],
      participantProfiles:
          (data['participantProfiles'] as List<dynamic>?)?.cast<String>() ?? [],
      participantProfilesData: profilesData ?? const [],
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTimestamp:
          (data['lastMessageTimestamp'] as Timestamp?)?.toDate() ??
              DateTime.now(),
      unreadCount: Map<String, int>.from((data['unreadCount'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0)) ??
          {}),
      archived: data['archived'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// From JSON
  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    return ConversationEntity(
      id: json['id'] as String? ?? '',
      participants:
          (json['participants'] as List<dynamic>?)?.cast<String>() ?? [],
      participantProfiles:
          (json['participantProfiles'] as List<dynamic>?)?.cast<String>() ?? [],
      participantProfilesData:
          (json['participantProfilesData'] as List<dynamic>?)
                  ?.map((e) => (e as Map).cast<String, dynamic>())
                  .toList() ??
              const [],
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTimestamp: json['lastMessageTimestamp'] != null
          ? DateTime.parse(json['lastMessageTimestamp'] as String)
          : DateTime.now(),
      unreadCount:
          (json['unreadCount'] as Map?)?.cast<String, int>() ?? const {},
      archived: json['archived'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
  final String id;
  final List<String> participants; // UIDs dos usuários
  final List<String> participantProfiles; // ProfileIds ativos na conversa
  final List<Map<String, dynamic>>
      participantProfilesData; // Dados completos dos perfis
  final String lastMessage; // Preview da última mensagem
  final DateTime lastMessageTimestamp;
  final Map<String, int> unreadCount; // profileId: count (não lidas)
  final bool archived; // Status de arquivamento
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Retorna unread count para um profileId específico
  int getUnreadCountForProfile(String profileId) {
    return unreadCount[profileId] ?? 0;
  }

  /// Retorna o outro participante (profileId) dado o profileId atual
  String? getOtherParticipantProfileId(String currentProfileId) {
    try {
      return participantProfiles.firstWhere(
        (id) => id != currentProfileId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Retorna o outro participante (UID) dado o UID atual
  String? getOtherParticipantUid(String currentUid) {
    try {
      return participants.firstWhere(
        (id) => id != currentUid,
      );
    } catch (e) {
      return null;
    }
  }

  /// To Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'participantProfiles': participantProfiles,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': Timestamp.fromDate(lastMessageTimestamp),
      'unreadCount': unreadCount,
      'archived': archived,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'participantProfiles': participantProfiles,
      'participantProfilesData': participantProfilesData,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp.toIso8601String(),
      'unreadCount': unreadCount,
      'archived': archived,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// CopyWith
  ConversationEntity copyWith({
    String? id,
    List<String>? participants,
    List<String>? participantProfiles,
    List<Map<String, dynamic>>? participantProfilesData,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    Map<String, int>? unreadCount,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      participantProfiles: participantProfiles ?? this.participantProfiles,
      participantProfilesData:
          participantProfilesData ?? this.participantProfilesData,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ConversationEntity(id: $id, participants: $participants, lastMessage: $lastMessage)';
  }
}
