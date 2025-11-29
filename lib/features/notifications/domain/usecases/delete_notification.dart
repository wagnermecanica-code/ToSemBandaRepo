import '../repositories/notifications_repository.dart';

class DeleteNotification {
  final NotificationsRepository _repository;
  DeleteNotification(this._repository);

  Future<void> call({
    required String notificationId,
    required String profileId,
  }) async {
    await _repository.deleteNotification(
      notificationId: notificationId,
      profileId: profileId,
    );
  }
}
