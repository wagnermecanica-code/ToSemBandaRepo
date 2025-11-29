import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/providers/stream_provider.dart';
import 'package:wegig_app/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:wegig_app/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:core_ui/features/notifications/domain/entities/notification_entity.dart';
import 'package:wegig_app/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:wegig_app/features/notifications/domain/usecases/create_notification.dart';
import 'package:wegig_app/features/notifications/domain/usecases/delete_notification.dart';
import 'package:wegig_app/features/notifications/domain/usecases/get_unread_notification_count.dart';
import 'package:wegig_app/features/notifications/domain/usecases/load_notifications.dart';
import 'package:wegig_app/features/notifications/domain/usecases/mark_all_notifications_as_read.dart';
import 'package:wegig_app/features/notifications/domain/usecases/mark_notification_as_read.dart';

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// Provider para FirebaseFirestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider para NotificationsRemoteDataSource
final notificationsRemoteDataSourceProvider =
    Provider<INotificationsRemoteDataSource>((ref) {
  return NotificationsRemoteDataSource();
});

/// Provider para NotificationsRepository (nova implementação Clean Architecture)
final notificationsRepositoryNewProvider =
    Provider<NotificationsRepository>((ref) {
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

final markNotificationAsReadUseCaseProvider =
    Provider<MarkNotificationAsRead>((ref) {
  final repository = ref.watch(notificationsRepositoryNewProvider);
  return MarkNotificationAsRead(repository);
});

final markAllNotificationsAsReadUseCaseProvider =
    Provider<MarkAllNotificationsAsRead>((ref) {
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

final getUnreadNotificationCountUseCaseProvider =
    Provider<GetUnreadNotificationCount>((ref) {
  final repository = ref.watch(notificationsRepositoryNewProvider);
  return GetUnreadNotificationCount(repository);
});

// ============================================================================
// STREAM PROVIDERS FOR REAL-TIME UPDATES
// ============================================================================

/// Stream de notificações em tempo real
final StreamProviderFamily<List<NotificationEntity>, String>
    notificationsStreamProvider =
    StreamProvider.family<List<NotificationEntity>, String>((ref, profileId) {
  final repository = ref.watch(notificationsRepositoryNewProvider);
  return repository.watchNotifications(profileId: profileId);
});

/// Stream de contador de não lidas para BottomNav badge
final StreamProviderFamily<int, String>
    unreadNotificationCountForProfileProvider =
    StreamProvider.family<int, String>((ref, profileId) {
  final repository = ref.watch(notificationsRepositoryNewProvider);
  return repository.watchUnreadCount(profileId: profileId);
});

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
Future<NotificationEntity> createNotificationAction(
  WidgetRef ref, {
  required NotificationEntity notification,
}) async {
  final useCase = ref.read(createNotificationUseCaseProvider);
  return useCase(notification);
}
