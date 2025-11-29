import '../repositories/notifications_repository.dart';

class MarkAllNotificationsAsRead {
  final NotificationsRepository _repository;
  MarkAllNotificationsAsRead(this._repository);

  Future<void> call({
    required String profileId,
  }) async {
    await _repository.markAllAsRead(
      profileId: profileId,
    );
  }
}
