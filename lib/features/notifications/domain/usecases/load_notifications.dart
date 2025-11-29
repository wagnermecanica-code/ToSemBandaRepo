import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

class LoadNotifications {
  final NotificationsRepository _repository;
  LoadNotifications(this._repository);

  Future<List<NotificationEntity>> call({
    required String profileId,
    int limit = 50,
    NotificationEntity? startAfter,
  }) async {
    return await _repository.getNotifications(
      profileId: profileId,
      limit: limit,
      startAfter: startAfter,
    );
  }
}
