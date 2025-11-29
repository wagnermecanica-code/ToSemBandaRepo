import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_entity.freezed.dart';
part 'message_entity.g.dart';

/// Domain entity para Mensagem individual
/// Suporta texto, imagens, reações e replies (responder)
@freezed
class MessageEntity with _$MessageEntity {
  const factory MessageEntity({
    required String messageId,
    required String senderId,              // UID do remetente
    required String senderProfileId,       // ProfileId do remetente
    required String text,                  // Conteúdo da mensagem
    String? imageUrl,                      // URL da imagem (opcional)
    MessageReplyEntity? replyTo,           // Mensagem sendo respondida
    @Default({}) Map<String, String> reactions, // uid: emoji
    @TimestampConverter() required DateTime timestamp,
    @Default(false) bool read,             // Status de leitura
  }) = _MessageEntity;

  const MessageEntity._();

  /// Getters úteis
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasText => text.isNotEmpty;
  bool get isReply => replyTo != null;
  bool get hasReactions => reactions.isNotEmpty;

  /// Preview da mensagem (para lista de conversas)
  String get preview {
    if (hasImage && !hasText) return '📷 Foto';
    if (hasText) return text.length > 50 ? '${text.substring(0, 50)}...' : text;
    return '';
  }

  /// Valida mensagem antes de enviar
  static String? validate(String text, String? imageUrl) {
    if (text.trim().isEmpty && imageUrl == null) {
      return 'Mensagem não pode ser vazia';
    }
    if (text.length > 1000) {
      return 'Mensagem muito longa (máximo 1000 caracteres)';
    }
    return null;
  }

  /// Sanitiza texto (preserva emojis, remove apenas controle chars)
  static String sanitize(String text) {
    var sanitized = text.trim();
    // Remove múltiplas quebras de linha consecutivas
    sanitized = sanitized.replaceAll(RegExp(r'\s*\n{2,}\s*'), '\n');
    // Remove caracteres de controle (mas preserva emojis)
    sanitized = sanitized.replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), '');
    return sanitized;
  }

  /// From Firestore Document
  factory MessageEntity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Message data is null');
    }

    return MessageEntity(
      messageId: snapshot.id,
      senderId: data['senderId'] as String? ?? '',
      senderProfileId: data['senderProfileId'] as String? ?? data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      replyTo: data['replyTo'] != null 
          ? MessageReplyEntity.fromMap(data['replyTo'] as Map<String, dynamic>)
          : null,
      reactions: Map<String, String>.from(
        (data['reactions'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {}
      ),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }

  /// To Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderProfileId': senderProfileId,
      'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (replyTo != null) 'replyTo': replyTo!.toMap(),
      'reactions': reactions,
      'timestamp': Timestamp.fromDate(timestamp),
      'read': read,
    };
  }

  factory MessageEntity.fromJson(Map<String, dynamic> json) => 
    _$MessageEntityFromJson(json);
}

/// Modelo de reply (resposta a uma mensagem)
@freezed
class MessageReplyEntity with _$MessageReplyEntity {
  const factory MessageReplyEntity({
    required String messageId,
    required String text,
    required String senderId,
    String? senderProfileId,
  }) = _MessageReplyEntity;

  const MessageReplyEntity._();

  factory MessageReplyEntity.fromMap(Map<String, dynamic> map) {
    return MessageReplyEntity(
      messageId: map['messageId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderProfileId: map['senderProfileId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'text': text,
      'senderId': senderId,
      if (senderProfileId != null) 'senderProfileId': senderProfileId,
    };
  }

  factory MessageReplyEntity.fromJson(Map<String, dynamic> json) => 
    _$MessageReplyEntityFromJson(json);
}

/// Custom converter for Timestamp
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
}
