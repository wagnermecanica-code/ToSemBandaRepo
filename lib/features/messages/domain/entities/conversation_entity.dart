import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_entity.freezed.dart';
part 'conversation_entity.g.dart';

/// Domain entity para Conversas (chat 1:1)
/// Suporta multi-perfil: cada perfil pode ter conversas independentes
@freezed
class ConversationEntity with _$ConversationEntity {
  const factory ConversationEntity({
    required String id,
    required List<String> participants,        // UIDs dos usuários
    required List<String> participantProfiles, // ProfileIds ativos na conversa
    required String lastMessage,               // Preview da última mensagem
    @TimestampConverter() required DateTime lastMessageTimestamp,
    required Map<String, int> unreadCount,     // profileId: count (não lidas)
    @Default(false) bool archived,             // Status de arquivamento
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _ConversationEntity;

  const ConversationEntity._();

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

  /// From Firestore Document
  factory ConversationEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Conversation data is null');
    }

    return ConversationEntity(
      id: snapshot.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantProfiles: List<String>.from(data['participantProfiles'] ?? []),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageTimestamp: (data['lastMessageTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(
        (data['unreadCount'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0)) ?? {}
      ),
      archived: data['archived'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
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

  factory ConversationEntity.fromJson(Map<String, dynamic> json) => 
    _$ConversationEntityFromJson(json);
}

/// Custom converter for Timestamp
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
}
