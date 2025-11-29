import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../data/datasources/notifications_remote_datasource.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/usecases/load_notifications.dart';
import '../../domain/usecases/mark_notification_as_read.dart';
import '../../domain/usecases/mark_all_notifications_as_read.dart';
import '../../domain/usecases/delete_notification.dart';
import '../../domain/usecases/create_notification.dart';
import '../../domain/usecases/get_unread_notification_count.dart';
import '../../domain/entities/notification_entity.dart';

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// Provider para FirebaseFirestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider para NotificationsRemoteDataSource
final notificationsRemoteDataSourceProvider = Provider<INotificationsRemoteDataSource>((ref) {
  return NotificationsRemoteDataSource();
});

/// Provider para NotificationsRepository (nova implementação Clean Architecture)
final notificationsRepositoryNewProvider = Provider<NotificationsRepository>((ref) {
  final dataSource = ref.watch(notificationsRemoteDataSourceProvider);
  return NotificationsRepositoryImpl(remoteDataSource: dataSource);
});

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================

final loadNotificationsUseCaseProvider = Provider<LoadNotifications>((ref) {
  final repository = ref.watch(notificationsRepositoryNewProvider);
  return LoadNotifications(repository);
});

final markNotificationAsReadUseCaseProvider = Provider<MarkNotificationAsRead>((ref) {
  final repository = ref.watch(notificationsRepositoryNewProvider);
  return MarkNotificationAsRead(repository);
});

final markAllNotificationsAsReadUseCaseProvider = Provider<MarkAllNotificationsAsRead>((ref) {
  final repository = ref.watch(notificationsRepositoryNewProvider);
  return MarkAllNotificationsAsRead(repository);
});

final deleteNotificationUseCaseProvider = Provider<DeleteNotification>((ref) {
  final repository = ref.watch(notificationsRepositoryNewProvider);
  return DeleteNotification(repository);
});

final createNotificationUseCaseProvider = Provider<CreateNotification>((ref) {
  final repository = ref.watch(notificationsRepositoryNewProvider);
  return CreateNotification(repository);
});

final getUnreadNotificationCountUseCaseProvider = Provider<GetUnreadNotificationCount>((ref) {
  final repository = ref.watch(notificationsRepositoryNewProvider);
  return GetUnreadNotificationCount(repository);
});

// ============================================================================
// STREAM PROVIDERS FOR REAL-TIME UPDATES
// ============================================================================

/// Stream de notificações em tempo real
final notificationsStreamProvider = StreamProvider.family<List<AppNotification>, String>((ref, profileId) {
  final repository = ref.watch(notificationsRepositoryNewProvider);
  return repository.watchNotifications(profileId: profileId).map((entities) {
    return entities.map((entity) => _entityToLegacy(entity)).toList();
  });
});

/// Stream de contador de não lidas para BottomNav badge
final unreadNotificationCountForProfileProvider = StreamProvider.family<int, String>((ref, profileId) {
  final repository = ref.watch(notificationsRepositoryNewProvider);
  return repository.watchUnreadCount(profileId: profileId);
});

// ============================================================================
// CONVERSION HELPERS (Entity ↔ Legacy Model)
// ============================================================================

/// Converte NotificationEntity para AppNotification (legacy)
AppNotification _entityToLegacy(NotificationEntity entity) {
  return AppNotification(
    notificationId: entity.notificationId,
    type: entity.type,
    recipientUid: entity.recipientUid,
    recipientProfileId: entity.recipientProfileId,
    senderUid: entity.senderUid,
    senderProfileId: entity.senderProfileId,
    senderName: entity.senderName,
    senderPhoto: entity.senderPhoto,
    title: entity.title,
    message: entity.message,
    data: entity.data,
    actionType: entity.actionType,
    actionData: entity.actionData,
    priority: entity.priority,
    createdAt: entity.createdAt,
    read: entity.read,
    readAt: entity.readAt,
    expiresAt: entity.expiresAt,
  );
}

/// Converte AppNotification (legacy) para NotificationEntity
NotificationEntity _legacyToEntity(AppNotification model) {
  return NotificationEntity(
    notificationId: model.notificationId,
    type: model.type,
    recipientUid: model.recipientUid,
    recipientProfileId: model.recipientProfileId,
    senderUid: model.senderUid,
    senderProfileId: model.senderProfileId,
    senderName: model.senderName,
    senderPhoto: model.senderPhoto,
    title: model.title,
    message: model.message,
    data: model.data,
    actionType: model.actionType,
    actionData: model.actionData,
    priority: model.priority,
    createdAt: model.createdAt,
    read: model.read,
    readAt: model.readAt,
    expiresAt: model.expiresAt,
  );
}

// ============================================================================
// HELPER FUNCTIONS FOR USE CASES
// ============================================================================

/// Marca notificação como lida
Future<void> markNotificationAsReadAction(
  WidgetRef ref, {
  required String notificationId,
  required String profileId,
}) async {
  final useCase = ref.read(markNotificationAsReadUseCaseProvider);
  await useCase(
    notificationId: notificationId,
    profileId: profileId,
  );
}

/// Marca todas notificações como lidas
Future<void> markAllNotificationsAsReadAction(
  WidgetRef ref, {
  required String profileId,
}) async {
  final useCase = ref.read(markAllNotificationsAsReadUseCaseProvider);
  await useCase(profileId: profileId);
}

/// Deleta notificação
Future<void> deleteNotificationAction(
  WidgetRef ref, {
  required String notificationId,
  required String profileId,
}) async {
  final useCase = ref.read(deleteNotificationUseCaseProvider);
  await useCase(
    notificationId: notificationId,
    profileId: profileId,
  );
}

/// Cria notificação
Future<AppNotification> createNotificationAction(
  WidgetRef ref, {
  required AppNotification notification,
}) async {
  final useCase = ref.read(createNotificationUseCaseProvider);
  final entity = _legacyToEntity(notification);
  final createdEntity = await useCase(entity);
  return _entityToLegacy(createdEntity);
}
