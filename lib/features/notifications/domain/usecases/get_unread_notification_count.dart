import '../repositories/notifications_repository.dart';

class GetUnreadNotificationCount {
  final NotificationsRepository _repository;
  GetUnreadNotificationCount(this._repository);

  Future<int> call({
    required String profileId,
  }) async {
    return await _repository.getUnreadCount(
      profileId: profileId,
    );
  }
}
