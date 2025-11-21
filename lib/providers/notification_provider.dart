import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationNotifier extends AsyncNotifier<List<AppNotification>> {
  late final INotificationRepository _repo;

  @override
  FutureOr<List<AppNotification>> build() async {
    _repo = ref.read(notificationRepositoryProvider);
    return _repo.getNotifications();
  }

  Future<void> refresh() async {
    state = AsyncValue.data(await _repo.getNotifications());
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<AppNotification>>(NotificationNotifier.new);
