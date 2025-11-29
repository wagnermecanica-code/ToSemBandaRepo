import 'package:cloud_firestore/cloud_firestore.dart';

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

/// Entidade de domínio para Notification (Clean Architecture)
class NotificationEntity {
  const NotificationEntity({
    required this.notificationId,
    required this.type,
    required this.recipientUid,
    required this.recipientProfileId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.senderUid,
    this.senderProfileId,
    this.senderName,
    this.senderPhoto,
    this.data = const {},
    this.actionType,
    this.actionData,
    this.priority = NotificationPriority.medium,
    this.read = false,
    this.readAt,
    this.expiresAt,
  });

  // ============================================================================
  // FIRESTORE SERIALIZATION
  // ============================================================================

  /// Cria NotificationEntity a partir de DocumentSnapshot
  factory NotificationEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
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

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      notificationId: json['notificationId'] as String? ?? '',
      type: parseType(json['type'] as String? ?? 'system'),
      recipientUid: json['recipientUid'] as String? ?? '',
      recipientProfileId: json['recipientProfileId'] as String? ?? '',
      senderUid: json['senderUid'] as String?,
      senderProfileId: json['senderProfileId'] as String?,
      senderName: json['senderName'] as String?,
      senderPhoto: json['senderPhoto'] as String?,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : {},
      actionType: json['actionType'] != null
          ? parseActionType(json['actionType'] as String)
          : null,
      actionData: json['actionData'] != null && json['actionData'] is Map
          ? Map<String, dynamic>.from(json['actionData'] as Map)
          : null,
      priority: parsePriority(json['priority'] as String? ?? 'medium'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      read: json['read'] as bool? ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }
  final String notificationId;
  final NotificationType type;
  final String recipientUid;
  final String recipientProfileId;
  final String? senderUid;
  final String? senderProfileId;
  final String? senderName;
  final String? senderPhoto;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final NotificationActionType? actionType;
  final Map<String, dynamic>? actionData;
  final NotificationPriority priority;
  final DateTime createdAt;
  final bool read;
  final DateTime? readAt;
  final DateTime? expiresAt;

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
  bool get hasAction =>
      actionType != null && actionType != NotificationActionType.none;

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

  // ============================================================================
  // COPY WITH
  // ============================================================================

  NotificationEntity copyWith({
    String? notificationId,
    NotificationType? type,
    String? recipientUid,
    String? recipientProfileId,
    String? senderUid,
    String? senderProfileId,
    String? senderName,
    String? senderPhoto,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    NotificationActionType? actionType,
    Map<String, dynamic>? actionData,
    NotificationPriority? priority,
    DateTime? createdAt,
    bool? read,
    DateTime? readAt,
    DateTime? expiresAt,
  }) {
    return NotificationEntity(
      notificationId: notificationId ?? this.notificationId,
      type: type ?? this.type,
      recipientUid: recipientUid ?? this.recipientUid,
      recipientProfileId: recipientProfileId ?? this.recipientProfileId,
      senderUid: senderUid ?? this.senderUid,
      senderProfileId: senderProfileId ?? this.senderProfileId,
      senderName: senderName ?? this.senderName,
      senderPhoto: senderPhoto ?? this.senderPhoto,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
      readAt: readAt ?? this.readAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // ============================================================================
  // JSON SERIALIZATION
  // ============================================================================

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
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
      'createdAt': createdAt.toIso8601String(),
      'read': read,
      'readAt': readAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  // ============================================================================
  // EQUALITY & HASH
  // ============================================================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationEntity &&
        other.notificationId == notificationId &&
        other.type == type &&
        other.recipientUid == recipientUid &&
        other.recipientProfileId == recipientProfileId &&
        other.senderUid == senderUid &&
        other.senderProfileId == senderProfileId &&
        other.senderName == senderName &&
        other.senderPhoto == senderPhoto &&
        other.title == title &&
        other.message == message &&
        other.actionType == actionType &&
        other.priority == priority &&
        other.createdAt == createdAt &&
        other.read == read &&
        other.readAt == readAt &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      notificationId,
      type,
      recipientUid,
      recipientProfileId,
      senderUid,
      senderProfileId,
      senderName,
      senderPhoto,
      title,
      message,
      actionType,
      priority,
      createdAt,
      read,
      readAt,
      expiresAt,
    );
  }

  @override
  String toString() {
    return 'NotificationEntity('
        'notificationId: $notificationId, '
        'type: $type, '
        'recipientUid: $recipientUid, '
        'recipientProfileId: $recipientProfileId, '
        'senderUid: $senderUid, '
        'senderProfileId: $senderProfileId, '
        'senderName: $senderName, '
        'senderPhoto: $senderPhoto, '
        'title: $title, '
        'message: $message, '
        'data: $data, '
        'actionType: $actionType, '
        'actionData: $actionData, '
        'priority: $priority, '
        'createdAt: $createdAt, '
        'read: $read, '
        'readAt: $readAt, '
        'expiresAt: $expiresAt'
        ')';
  }
}
