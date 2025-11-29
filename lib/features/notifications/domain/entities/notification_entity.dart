import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'notification_entity.freezed.dart';

/// Tipos de notificação suportados (9 tipos)
enum NotificationType {
  interest,
  newMessage,
  postExpiring,
  nearbyPost,
  profileMatch,
  interestResponse,
  postUpdated,
  profileView,
  system,
}

/// Prioridade da notificação
enum NotificationPriority {
  low,
  medium,
  high,
}

/// Tipo de ação da notificação
enum NotificationActionType {
  navigate,
  openChat,
  viewPost,
  viewProfile,
  renewPost,
  none,
}

/// Conversor customizado para Timestamp ↔ DateTime
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}

/// Conversor customizado para Timestamp? ↔ DateTime?
class NullableTimestampConverter implements JsonConverter<DateTime?, Timestamp?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  @override
  Timestamp? toJson(DateTime? dateTime) {
    return dateTime != null ? Timestamp.fromDate(dateTime) : null;
  }
}

/// Entidade de domínio para Notification
@freezed
class NotificationEntity with _$NotificationEntity {
  const NotificationEntity._();

  const factory NotificationEntity({
    required String notificationId,
    required NotificationType type,
    required String recipientUid,
    required String recipientProfileId,
    String? senderUid,
    String? senderProfileId,
    String? senderName,
    String? senderPhoto,
    required String title,
    required String message,
    @Default({}) Map<String, dynamic> data,
    NotificationActionType? actionType,
    Map<String, dynamic>? actionData,
    @Default(NotificationPriority.medium) NotificationPriority priority,
    @TimestampConverter() required DateTime createdAt,
    @Default(false) bool read,
    @NullableTimestampConverter() DateTime? readAt,
    @NullableTimestampConverter() DateTime? expiresAt,
  }) = _NotificationEntity;

  // ============================================================================
  // GETTERS
  // ============================================================================

  /// Se a notificação está expirada
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Se a notificação tem remetente
  bool get hasSender => senderUid != null && senderProfileId != null;

  /// Se a notificação tem ação
  bool get hasAction => actionType != null && actionType != NotificationActionType.none;

  /// Ícone baseado no tipo
  String get iconName {
    switch (type) {
      case NotificationType.interest:
        return 'favorite';
      case NotificationType.newMessage:
        return 'message';
      case NotificationType.postExpiring:
        return 'schedule';
      case NotificationType.nearbyPost:
        return 'location_on';
      case NotificationType.profileMatch:
        return 'people';
      case NotificationType.interestResponse:
        return 'notifications';
      case NotificationType.postUpdated:
        return 'update';
      case NotificationType.profileView:
        return 'visibility';
      case NotificationType.system:
        return 'info';
    }
  }

  // ============================================================================
  // FIRESTORE SERIALIZATION
  // ============================================================================

  /// Cria NotificationEntity a partir de DocumentSnapshot
  factory NotificationEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;

    return NotificationEntity(
      notificationId: id,
      type: parseType(data['type'] as String? ?? 'system'),
      recipientUid: data['recipientUid'] as String? ?? '',
      recipientProfileId: data['recipientProfileId'] as String? ?? '',
      senderUid: data['senderUid'] as String?,
      senderProfileId: data['senderProfileId'] as String?,
      senderName: data['senderName'] as String?,
      senderPhoto: data['senderPhoto'] as String?,
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      data: data['data'] != null && data['data'] is Map
          ? Map<String, dynamic>.from(data['data'] as Map)
          : {},
      actionType: data['actionType'] != null
          ? parseActionType(data['actionType'] as String)
          : null,
      actionData: data['actionData'] != null && data['actionData'] is Map
          ? Map<String, dynamic>.from(data['actionData'] as Map)
          : null,
      priority: parsePriority(data['priority'] as String? ?? 'medium'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converte NotificationEntity para Map do Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'recipientUid': recipientUid,
      'recipientProfileId': recipientProfileId,
      'senderUid': senderUid,
      'senderProfileId': senderProfileId,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
      'title': title,
      'message': message,
      'data': data,
      'actionType': actionType?.name,
      'actionData': actionData,
      'priority': priority.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'read': read,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  // ============================================================================
  // PARSERS (STATIC - PUBLIC for legacy model compatibility)
  // ============================================================================

  static NotificationType parseType(String type) {
    switch (type) {
      case 'interest':
        return NotificationType.interest;
      case 'newMessage':
        return NotificationType.newMessage;
      case 'postExpiring':
        return NotificationType.postExpiring;
      case 'nearbyPost':
        return NotificationType.nearbyPost;
      case 'profileMatch':
        return NotificationType.profileMatch;
      case 'interestResponse':
        return NotificationType.interestResponse;
      case 'postUpdated':
        return NotificationType.postUpdated;
      case 'profileView':
        return NotificationType.profileView;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }

  static NotificationPriority parsePriority(String priority) {
    switch (priority) {
      case 'low':
        return NotificationPriority.low;
      case 'high':
        return NotificationPriority.high;
      default:
        return NotificationPriority.medium;
    }
  }

  static NotificationActionType parseActionType(String actionType) {
    switch (actionType) {
      case 'navigate':
        return NotificationActionType.navigate;
      case 'openChat':
        return NotificationActionType.openChat;
      case 'viewPost':
        return NotificationActionType.viewPost;
      case 'viewProfile':
        return NotificationActionType.viewProfile;
      case 'renewPost':
        return NotificationActionType.renewPost;
      default:
        return NotificationActionType.none;
    }
  }

  // ============================================================================
  // VALIDATION
  // ============================================================================

  /// Valida campos obrigatórios
  static void validate({
    required String recipientUid,
    required String recipientProfileId,
    required String title,
    required String message,
  }) {
    if (recipientUid.trim().isEmpty) {
      throw Exception('recipientUid é obrigatório');
    }
    if (recipientProfileId.trim().isEmpty) {
      throw Exception('recipientProfileId é obrigatório');
    }
    if (title.trim().isEmpty) {
      throw Exception('title é obrigatório');
    }
    if (message.trim().isEmpty) {
      throw Exception('message é obrigatório');
    }
  }
}
