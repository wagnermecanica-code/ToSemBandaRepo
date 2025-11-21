import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipos de notificação suportados
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

/// Modelo de notificação unificado
class AppNotification {
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

  AppNotification({
    required this.notificationId,
    required this.type,
    required this.recipientUid,
    required this.recipientProfileId,
    this.senderUid,
    this.senderProfileId,
    this.senderName,
    this.senderPhoto,
    required this.title,
    required this.message,
    this.data = const {},
    this.actionType,
    this.actionData,
    this.priority = NotificationPriority.medium,
    required this.createdAt,
    this.read = false,
    this.readAt,
    this.expiresAt,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    final typeStr = map['type'] as String? ?? 'system';
    // Defensive reads with sensible defaults to avoid crashes from malformed/legacy docs
    final recipientUid = map['recipientUid'] as String? ?? '';
    final recipientProfileId = map['recipientProfileId'] as String? ?? recipientUid;
    final senderUid = map['senderUid'] as String?;
    final senderProfileId = map['senderProfileId'] as String?;
    final senderName = map['senderName'] as String?;
    final senderPhoto = map['senderPhoto'] as String?;
    final title = map['title'] as String? ?? '';
    final message = map['message'] as String? ?? '';
    final data = (map['data'] != null && map['data'] is Map)
      ? Map<String, dynamic>.from(map['data'] as Map)
      : <String, dynamic>{};
    final actionType = map['actionType'] != null && map['actionType'] is String
      ? _parseActionType(map['actionType'] as String)
      : null;
    final actionData = map['actionData'] != null && map['actionData'] is Map
      ? Map<String, dynamic>.from(map['actionData'] as Map)
      : null;
    final priority = _parsePriority(map['priority'] as String? ?? 'medium');
    final createdAt = map['createdAt'] != null && map['createdAt'] is Timestamp
      ? (map['createdAt'] as Timestamp).toDate()
      : DateTime.now();
    final read = map['read'] as bool? ?? false;
    final readAt = map['readAt'] != null && map['readAt'] is Timestamp
      ? (map['readAt'] as Timestamp).toDate()
      : null;
    final expiresAt = map['expiresAt'] != null && map['expiresAt'] is Timestamp
      ? (map['expiresAt'] as Timestamp).toDate()
      : null;

    return AppNotification(
      notificationId: id,
      type: _parseType(typeStr),
      recipientUid: recipientUid,
      recipientProfileId: recipientProfileId,
      senderUid: senderUid,
      senderProfileId: senderProfileId,
      senderName: senderName,
      senderPhoto: senderPhoto,
      title: title,
      message: message,
      data: data,
      actionType: actionType,
      actionData: actionData,
      priority: priority,
      createdAt: createdAt,
      read: read,
      readAt: readAt,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toMap() {
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

  static NotificationType _parseType(String type) {
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

  static NotificationPriority _parsePriority(String priority) {
    switch (priority) {
      case 'low':
        return NotificationPriority.low;
      case 'high':
        return NotificationPriority.high;
      default:
        return NotificationPriority.medium;
    }
  }

  static NotificationActionType _parseActionType(String actionType) {
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

  AppNotification copyWith({
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
    return AppNotification(
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
}
