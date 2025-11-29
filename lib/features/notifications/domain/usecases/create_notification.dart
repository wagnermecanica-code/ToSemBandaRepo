import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

class CreateNotification {
  final NotificationsRepository _repository;
  CreateNotification(this._repository);

  Future<NotificationEntity> call(NotificationEntity notification) async {
    // Validação
    NotificationEntity.validate(
      recipientUid: notification.recipientUid,
      recipientProfileId: notification.recipientProfileId,
      title: notification.title,
      message: notification.message,
    );

    return await _repository.createNotification(notification);
  }
}
