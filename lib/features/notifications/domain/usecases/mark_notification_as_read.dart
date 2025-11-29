import '../repositories/notifications_repository.dart';

class MarkNotificationAsRead {
  final NotificationsRepository _repository;
  MarkNotificationAsRead(this._repository);

  Future<void> call({
    required String notificationId,
    required String profileId,
  }) async {
    await _repository.markAsRead(
      notificationId: notificationId,
      profileId: profileId,
    );
  }
}
