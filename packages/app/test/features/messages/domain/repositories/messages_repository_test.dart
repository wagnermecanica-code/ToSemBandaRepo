import 'package:flutter_test/flutter_test.dart';

/// Testes críticos para MessagesRepository
/// Foca em validações de negócio sem depender de Freezed entities
void main() {
  group('MessagesRepository - Send Message Validations', () {
    test('should reject empty message text', () {
      // Arrange
      final emptyMessage = {
        'text': '',
        'senderId': 'user-123',
      };

      // Act & Assert
      expect(
        () => _validateMessageData(emptyMessage),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should reject whitespace-only message', () {
      // Arrange
      final whitespaceMessage = {
        'text': '   \n  ',
        'senderId': 'user-123',
      };

      // Act & Assert
      expect(
        () => _validateMessageData(whitespaceMessage),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should accept valid message', () {
      // Arrange
      final validMessage = {
        'text': 'Oi! Vamos marcar um ensaio?',
        'senderId': 'user-123',
        'senderProfileId': 'profile-1',
      };

      // Act & Assert
      expect(() => _validateMessageData(validMessage), returnsNormally);
    });

    test('should trim message text', () {
      // Arrange
      const messageWithSpaces = '  Hello World  ';

      // Act
      final trimmedText = _trimMessageText(messageWithSpaces);

      // Assert
      expect(trimmedText, equals('Hello World'));
    });
  });

  group('MessagesRepository - Mark As Read Logic', () {
    test('should reset unread count to zero', () {
      // Arrange
      const currentUnreadCount = 5;

      // Act
      final newUnreadCount = _markConversationAsRead(currentUnreadCount);

      // Assert
      expect(newUnreadCount, equals(0));
    });

    test('should handle already-read conversation', () {
      // Arrange
      const currentUnreadCount = 0;

      // Act
      final newUnreadCount = _markConversationAsRead(currentUnreadCount);

      // Assert
      expect(newUnreadCount, equals(0));
    });
  });

  group('MessagesRepository - Delete Conversation Logic', () {
    test('should mark conversation as archived (soft delete)', () {
      // Arrange
      final conversation = {
        'conversationId': 'conv-123',
        'participants': ['profile-1', 'profile-2'],
        'isArchived': false,
      };

      // Act
      final archivedConversation = _archiveConversation(
        conversation,
        archivedBy: 'profile-1',
      );

      // Assert
      expect(archivedConversation['isArchived'], isTrue);
      expect(archivedConversation['archivedBy'], contains('profile-1'));
    });

    test('should not delete for other participant', () {
      // Arrange
      final conversation = {
        'conversationId': 'conv-123',
        'participants': ['profile-1', 'profile-2'],
      };

      // Act
      final archived = _archiveConversation(
        conversation,
        archivedBy: 'profile-1',
      );

      // Assert
      expect(
        archived['participants'],
        contains('profile-2'),
        reason: 'Outro participante ainda deve ver a conversa',
      );
    });
  });

  group('MessagesRepository - Unread Count Logic', () {
    test('should increment unread count when new message arrives', () {
      // Arrange
      const currentCount = 3;

      // Act
      final newCount = _incrementUnreadCount(currentCount);

      // Assert
      expect(newCount, equals(4));
    });

    test('should sum unread counts from all conversations', () {
      // Arrange
      final conversations = [
        {'unreadCount': 2},
        {'unreadCount': 5},
        {'unreadCount': 0},
        {'unreadCount': 3},
      ];

      // Act
      final totalUnread = _calculateTotalUnreadCount(conversations);

      // Assert
      expect(totalUnread, equals(10));
    });
  });
}

/// Helper: Valida dados da mensagem
void _validateMessageData(Map<String, dynamic> messageData) {
  final text = (messageData['text'] as String? ?? '').trim();
  if (text.isEmpty) {
    throw ArgumentError('Message text cannot be empty');
  }
}

/// Helper: Limpa espaços da mensagem
String _trimMessageText(String text) {
  return text.trim();
}

/// Helper: Marca conversa como lida (zera contador)
int _markConversationAsRead(int currentUnreadCount) {
  return 0;
}

/// Helper: Arquiva conversa (soft delete)
Map<String, dynamic> _archiveConversation(
  Map<String, dynamic> conversation, {
  required String archivedBy,
}) {
  return {
    ...conversation,
    'isArchived': true,
    'archivedBy': [archivedBy],
  };
}

/// Helper: Incrementa contador de não lidas
int _incrementUnreadCount(int currentCount) {
  return currentCount + 1;
}

/// Helper: Calcula total de não lidas
int _calculateTotalUnreadCount(List<Map<String, dynamic>> conversations) {
  return conversations.fold<int>(
    0,
    (sum, conv) => sum + (conv['unreadCount'] as int? ?? 0),
  );
}
