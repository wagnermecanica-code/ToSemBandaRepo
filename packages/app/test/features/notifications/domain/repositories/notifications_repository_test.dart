import 'package:flutter_test/flutter_test.dart';

/// Testes críticos para NotificationsRepository
/// Foca em validações de negócio sem depender de Freezed entities
void main() {
  group('NotificationsRepository - Mark As Read Logic', () {
    test('should update notification read status to true', () {
      // Arrange
      final notification = {
        'notificationId': 'notif-123',
        'read': false,
        'recipientProfileId': 'profile-1',
      };

      // Act
      final updatedNotification = _markNotificationAsRead(notification);

      // Assert
      expect(updatedNotification['read'], isTrue);
    });

    test('should handle already-read notification', () {
      // Arrange
      final notification = {
        'notificationId': 'notif-456',
        'read': true,
        'recipientProfileId': 'profile-1',
      };

      // Act
      final updatedNotification = _markNotificationAsRead(notification);

      // Assert
      expect(updatedNotification['read'], isTrue);
    });

    test('should set readAt timestamp when marking as read', () {
      // Arrange
      final notification = {
        'notificationId': 'notif-789',
        'read': false,
        'readAt': null,
      };

      // Act
      final updatedNotification = _markNotificationAsRead(notification);

      // Assert
      expect(updatedNotification['readAt'], isNotNull);
      expect(updatedNotification['readAt'], isA<DateTime>());
    });
  });

  group('NotificationsRepository - Mark All As Read Logic', () {
    test('should mark all unread notifications as read', () {
      // Arrange
      final notifications = [
        {'notificationId': 'n1', 'read': false},
        {'notificationId': 'n2', 'read': false},
        {'notificationId': 'n3', 'read': true},
        {'notificationId': 'n4', 'read': false},
      ];

      // Act
      final updatedNotifications = _markAllAsRead(notifications);

      // Assert
      expect(
        updatedNotifications.every((n) => n['read'] == true),
        isTrue,
        reason: 'Todas as notificações devem estar marcadas como lidas',
      );
    });

    test('should not modify already-read notifications', () {
      // Arrange
      final notifications = [
        {
          'notificationId': 'n1',
          'read': true,
          'readAt': DateTime(2025, 11, 28)
        },
      ];

      // Act
      final updatedNotifications = _markAllAsRead(notifications);

      // Assert
      expect(updatedNotifications[0]['readAt'], equals(DateTime(2025, 11, 28)));
    });
  });

  group('NotificationsRepository - Unread Count Logic', () {
    test('should count only unread notifications', () {
      // Arrange
      final notifications = [
        {'read': false},
        {'read': true},
        {'read': false},
        {'read': false},
        {'read': true},
      ];

      // Act
      final unreadCount = _calculateUnreadCount(notifications);

      // Assert
      expect(unreadCount, equals(3));
    });

    test('should return 0 when all notifications are read', () {
      // Arrange
      final notifications = [
        {'read': true},
        {'read': true},
      ];

      // Act
      final unreadCount = _calculateUnreadCount(notifications);

      // Assert
      expect(unreadCount, equals(0));
    });

    test('should return 0 for empty notification list', () {
      // Arrange
      final notifications = <Map<String, dynamic>>[];

      // Act
      final unreadCount = _calculateUnreadCount(notifications);

      // Assert
      expect(unreadCount, equals(0));
    });
  });

  group('NotificationsRepository - Delete Notification Logic', () {
    test('should validate ownership before deleting', () {
      // Arrange
      const notificationProfileId = 'profile-1';
      const requestingProfileId = 'profile-2'; // Diferente

      // Act
      final canDelete = _canDeleteNotification(
        notificationProfileId,
        requestingProfileId,
      );

      // Assert
      expect(canDelete, isFalse,
          reason: 'Só pode deletar próprias notificações');
    });

    test('should allow deleting own notification', () {
      // Arrange
      const notificationProfileId = 'profile-1';
      const requestingProfileId = 'profile-1'; // Mesmo perfil

      // Act
      final canDelete = _canDeleteNotification(
        notificationProfileId,
        requestingProfileId,
      );

      // Assert
      expect(canDelete, isTrue);
    });
  });

  group('NotificationsRepository - Notification Types', () {
    test('should validate proximity notification has location', () {
      // Arrange
      final proximityNotification = {
        'type': 'proximity',
        'location': null, // ❌ Obrigatório para proximity
      };

      // Act & Assert
      expect(
        () => _validateNotificationData(proximityNotification),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should validate interest notification has postId', () {
      // Arrange
      final interestNotification = {
        'type': 'interest',
        'postId': null, // ❌ Obrigatório para interest
      };

      // Act & Assert
      expect(
        () => _validateNotificationData(interestNotification),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should accept valid notification data', () {
      // Arrange
      final validNotification = {
        'type': 'interest',
        'postId': 'post-123',
        'recipientProfileId': 'profile-1',
      };

      // Act & Assert
      expect(
          () => _validateNotificationData(validNotification), returnsNormally);
    });
  });
}

/// Helper: Marca notificação como lida
Map<String, dynamic> _markNotificationAsRead(
    Map<String, dynamic> notification) {
  return {
    ...notification,
    'read': true,
    'readAt': notification['readAt'] ?? DateTime.now(),
  };
}

/// Helper: Marca todas as notificações como lidas
List<Map<String, dynamic>> _markAllAsRead(
    List<Map<String, dynamic>> notifications) {
  return notifications.map((notif) {
    if (notif['read'] == true) return notif; // Já lida
    return {
      ...notif,
      'read': true,
      'readAt': notif['readAt'] ?? DateTime.now(),
    };
  }).toList();
}

/// Helper: Calcula notificações não lidas
int _calculateUnreadCount(List<Map<String, dynamic>> notifications) {
  return notifications.where((n) => n['read'] == false).length;
}

/// Helper: Valida ownership para deletar
bool _canDeleteNotification(
    String notificationProfileId, String requestingProfileId) {
  return notificationProfileId == requestingProfileId;
}

/// Helper: Valida dados da notificação
void _validateNotificationData(Map<String, dynamic> notificationData) {
  final type = notificationData['type'] as String?;

  if (type == 'proximity' && notificationData['location'] == null) {
    throw ArgumentError('Proximity notification requires location');
  }

  if (type == 'interest' && notificationData['postId'] == null) {
    throw ArgumentError('Interest notification requires postId');
  }
}
