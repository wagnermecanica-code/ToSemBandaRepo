import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

abstract class INotificationRepository {
  Future<List<AppNotification>> getNotifications();
}

class NotificationRepository implements INotificationRepository {
  @override
  Future<List<AppNotification>> getNotifications() async {
    // TODO: Implement Firestore query
    throw UnimplementedError();
  }
}

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepository();
});
