import 'package:cloud_firestore/cloud_firestore.dart';

/// Domain entity para Mensagem individual
/// Suporta texto, imagens, reações e replies (responder)
class MessageEntity {
  // Status de leitura

  const MessageEntity({
    required this.messageId,
    required this.senderId,
    required this.senderProfileId,
    required this.text,
    required this.timestamp,
    this.imageUrl,
    this.replyTo,
    this.reactions = const {},
    this.read = false,
  });

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
      senderProfileId: data['senderProfileId'] as String? ??
          data['senderId'] as String? ??
          '',
      text: data['text'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      replyTo: data['replyTo'] != null
          ? MessageReplyEntity.fromMap(data['replyTo'] as Map<String, dynamic>)
          : null,
      reactions: Map<String, String>.from((data['reactions'] as Map?)
              ?.map((k, v) => MapEntry(k.toString(), v.toString())) ??
          {}),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
    );
  }

  /// From JSON
  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    return MessageEntity(
      messageId: json['messageId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderProfileId: json['senderProfileId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      replyTo: json['replyTo'] != null
          ? MessageReplyEntity.fromMap(
              (json['replyTo'] as Map).cast<String, dynamic>())
          : null,
      reactions:
          (json['reactions'] as Map?)?.cast<String, String>() ?? const {},
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      read: json['read'] as bool? ?? false,
    );
  }
  final String messageId;
  final String senderId; // UID do remetente
  final String senderProfileId; // ProfileId do remetente
  final String text; // Conteúdo da mensagem
  final String? imageUrl; // URL da imagem (opcional)
  final MessageReplyEntity? replyTo; // Mensagem sendo respondida
  final Map<String, String> reactions; // uid: emoji
  final DateTime timestamp;
  final bool read;

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

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderProfileId': senderProfileId,
      'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (replyTo != null) 'replyTo': replyTo!.toMap(),
      'reactions': reactions,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
    };
  }

  /// CopyWith
  MessageEntity copyWith({
    String? messageId,
    String? senderId,
    String? senderProfileId,
    String? text,
    String? imageUrl,
    MessageReplyEntity? replyTo,
    Map<String, String>? reactions,
    DateTime? timestamp,
    bool? read,
  }) {
    return MessageEntity(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      senderProfileId: senderProfileId ?? this.senderProfileId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageEntity && other.messageId == messageId;
  }

  @override
  int get hashCode => messageId.hashCode;

  @override
  String toString() {
    return 'MessageEntity(messageId: $messageId, text: $text, read: $read)';
  }
}

/// Modelo de reply (resposta a uma mensagem)
class MessageReplyEntity {
  const MessageReplyEntity({
    required this.messageId,
    required this.text,
    required this.senderId,
    this.senderProfileId,
  });

  factory MessageReplyEntity.fromMap(Map<String, dynamic> map) {
    return MessageReplyEntity(
      messageId: map['messageId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderProfileId: map['senderProfileId'] as String?,
    );
  }

  factory MessageReplyEntity.fromJson(Map<String, dynamic> json) {
    return MessageReplyEntity.fromMap(json);
  }
  final String messageId;
  final String text;
  final String senderId;
  final String? senderProfileId;

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'text': text,
      'senderId': senderId,
      if (senderProfileId != null) 'senderProfileId': senderProfileId,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  MessageReplyEntity copyWith({
    String? messageId,
    String? text,
    String? senderId,
    String? senderProfileId,
  }) {
    return MessageReplyEntity(
      messageId: messageId ?? this.messageId,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      senderProfileId: senderProfileId ?? this.senderProfileId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageReplyEntity && other.messageId == messageId;
  }

  @override
  int get hashCode => messageId.hashCode;

  @override
  String toString() {
    return 'MessageReplyEntity(messageId: $messageId, text: $text)';
  }
}
